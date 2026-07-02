import NavigationKit
import SwiftUI

public enum ScheduleRouteBuilder {
    @MainActor
    public static func register(
        in registry: RouteBuilder,
        speakerAvatarProvider: ((String) -> Image?)? = nil
    ) {
        registry.register(ScheduleRoute.self) { route, navigator in
            switch route {
            case .list:
                ScheduleView(onSessionTapped: { id in
                    navigator.push(ScheduleRoute.session(id: id))
                })
            case let .session(id):
                SessionView(
                    id: id,
                    speakerAvatarProvider: speakerAvatarProvider,
                    onSpeakerTapped: { speakerId in
                        if let url = URL(string: "navigator://speakers/speaker/\(speakerId)") {
                            UIApplication.shared.open(url)
                        }
                    },
                    onAddToMyConfTapped: {
                        if let session = SessionMock.sessions.first(where: { $0.id == id }) {
                            var existing: [[String: String]] = []
                            if let data = UserDefaults.standard.string(forKey: "saved_session_json")?.data(using: .utf8) {
                                existing = (try? JSONDecoder().decode([[String: String]].self, from: data)) ?? []
                            }
                            let dict = ["id": session.id, "title": session.title, "time": session.time, "room": session.room]
                            // Only add if not already present
                            if !existing.contains(where: { $0["id"] == session.id }) {
                                existing.append(dict)
                                if let data = try? JSONEncoder().encode(existing), let string = String(data: data, encoding: .utf8) {
                                    UserDefaults.standard.set(string, forKey: "saved_session_json")
                                }
                            }
                        }
                        
                        navigator.present(
                            alert: AlertSpec(
                                title: "Added to MyConf",
                                message: "This session has been saved to your personal schedule.",
                                buttons: [
                                    AlertSpec.Button("view_saved_sessions") {
                                        if let url = URL(string: "navigator://myconf/savedSessions") {
                                            UIApplication.shared.open(url)
                                        }
                                    },
                                    AlertSpec.Button("OK", role: .cancel)
                                ]
                            )
                        )
                    }
                )
            }
        }
    }
}
