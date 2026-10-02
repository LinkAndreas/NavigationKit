import NavigationKit
import SwiftUI

/// Schedule screens need a dependency from the app (speaker avatars), which the app passes in
/// when it lists the module.
public struct ScheduleModule: RouteModule {
    private let speakerAvatarProvider: ((String) -> Image?)?

    public init(speakerAvatarProvider: ((String) -> Image?)? = nil) {
        self.speakerAvatarProvider = speakerAvatarProvider
    }

    public func body(for route: ScheduleRoute, navigator: RouteNavigator<ScheduleRoute>) -> some View {
        switch route {
        case .list:
            // `show` fills the detail column on iPad and pushes on iPhone.
            ScheduleView(onSessionTapped: { navigator.show(.session(id: $0)) })
        case .placeholder:
            ContentUnavailableView("Select a session", systemImage: "calendar")
        case let .session(id):
            SessionView(
                id: id,
                speakerAvatarProvider: speakerAvatarProvider,
                onSpeakerTapped: { speakerId in
                    if let url = URL(string: "navigator://speakers/speaker/\(speakerId)") {
                        navigator.open(url)
                    }
                },
                onAddToMyConfTapped: {
                    SessionStore.save(sessionID: id)
                    navigator.dialog(
                        "Added to MyConf",
                        message: "This session has been saved to your personal schedule."
                    ) {
                        Dialog.Action("view_saved_sessions") {
                            if let url = URL(string: "navigator://myconf/savedSessions") { navigator.open(url) }
                        }
                        Dialog.Action("OK", role: .cancel)
                    }
                }
            )
        }
    }
}

enum SessionStore {
    static func save(sessionID id: String) {
        guard let session = SessionMock.sessions.first(where: { $0.id == id }) else { return }
        var existing: [[String: String]] = []
        if let data = UserDefaults.standard.string(forKey: "saved_session_json")?.data(using: .utf8) {
            existing = (try? JSONDecoder().decode([[String: String]].self, from: data)) ?? []
        }
        guard !existing.contains(where: { $0["id"] == session.id }) else { return }
        existing.append(["id": session.id, "title": session.title, "time": session.time, "room": session.room])
        if let data = try? JSONEncoder().encode(existing), let string = String(data: data, encoding: .utf8) {
            UserDefaults.standard.set(string, forKey: "saved_session_json")
        }
    }
}
