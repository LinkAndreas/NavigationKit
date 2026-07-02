import SwiftUI
import MessageUI

struct SpeakerDetailsScreen: View {
    let speakerId: String
    let onContactTapped: (String) -> Void
    @Environment(\.openURL) private var openURL
    
    var speaker: Speaker? {
        SpeakerMock.speakers.first(where: { $0.id == speakerId })
    }

    var body: some View {
        if let speaker = speaker {
            ScrollView {
                VStack(spacing: 24) {
                    Image(speaker.imageName, bundle: .module)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .shadow(radius: 10)
                        .padding(.top, 20)
                    
                    VStack(spacing: 8) {
                        Text(speaker.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("role_company")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(speaker.bio)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        Button(action: {
                            let email = "\(speaker.name.lowercased().replacingOccurrences(of: " ", with: "."))@example.com"
                            onContactTapped(email)
                        }) {
                            HStack {
                                Image(systemName: "envelope.fill")
                                Text("contact_speaker")
                                Spacer()
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
                        // Added realistic useful feature: View upcoming sessions
                        Button(action: {
                            if let url = URL(string: "navigator://schedule") {
                                openURL(url)
                            }
                        }) {
                            HStack {
                                Image(systemName: "calendar.badge.clock")
                                Text("view_upcoming_sessions")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle(speaker.name)
            .navigationBarTitleDisplayMode(.inline)
        } else {
            Text("speaker_not_found")
        }
    }
}
