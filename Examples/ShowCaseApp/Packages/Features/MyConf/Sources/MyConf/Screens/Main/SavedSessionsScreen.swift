import SwiftUI

public struct SavedSessionJSON: Codable, Hashable, Identifiable {
    public let id: String
    public let title: String
    public let time: String
    public let room: String
    
    public init(id: String, title: String, time: String, room: String) {
        self.id = id
        self.title = title
        self.time = time
        self.room = room
    }
}

public struct SavedSessionsScreen: View {
    @AppStorage("saved_session_json") private var savedSessionsString: String = "[]"
    
    private var sessions: [SavedSessionJSON] {
        guard let data = savedSessionsString.data(using: .utf8) else { return [] }
        return (try? JSONDecoder().decode([SavedSessionJSON].self, from: data)) ?? []
    }

    public var body: some View {
        List {
            if sessions.isEmpty {
                Text("No saved sessions yet.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(sessions) { session in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(session.title)
                            .font(.headline)
                        Text("\(session.time) • \(session.room)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete { indexSet in
                    var current = sessions
                    current.remove(atOffsets: indexSet)
                    if let data = try? JSONEncoder().encode(current),
                       let string = String(data: data, encoding: .utf8) {
                        savedSessionsString = string
                    }
                }
            }
        }
        .navigationTitle("Saved Sessions")
    }
}
