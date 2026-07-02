import NavigationKit
import SwiftUI

struct SessionView: View {
    let id: String
    let speakerAvatarProvider: ((String) -> Image?)?
    let onSpeakerTapped: (String) -> Void
    let onAddToMyConfTapped: () -> Void

    var session: Session? {
        SessionMock.sessions.first(where: { $0.id == id })
    }

    var body: some View {
        ScrollView {
            if let session = session {
                VStack(alignment: .leading, spacing: 20) {
                    Text(session.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                    
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.blue)
                        Text(session.time)
                            .font(.headline)
                        
                        Spacer()
                        
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(.red)
                        Text(session.room)
                            .font(.headline)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    Text("abstract")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(session.abstract)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                    
                    Text("speaker")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 10)
                    
                    Button {
                        onSpeakerTapped(session.speakerId)
                    } label: {
                        HStack {
                            if let provider = speakerAvatarProvider, let image = provider(session.speakerId) {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.blue)
                            }
                            
                            VStack(alignment: .leading) {
                                Text(session.speakerName)
                                    .font(.headline)
                                Text("tap_to_view_profile")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)

                    Spacer(minLength: 40)
                    
                    Button {
                        onAddToMyConfTapped()
                    } label: {
                        Text("add_to_myconf")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                }
                .padding()
            } else {
                Text("session_not_found")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("session_details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
