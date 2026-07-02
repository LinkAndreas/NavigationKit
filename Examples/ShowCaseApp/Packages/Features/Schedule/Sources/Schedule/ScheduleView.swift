import NavigationKit
import SwiftUI

struct ScheduleView: View {
    let onSessionTapped: (String) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(SessionMock.sessions) { session in
                    Button {
                        onSessionTapped(session.id)
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(session.time)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                Spacer()
                                Text(session.category)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                                    .foregroundColor(.blue)
                            }
                            
                            Text(session.title)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text("speakername_room")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .navigationTitle("schedule")
    }
}
