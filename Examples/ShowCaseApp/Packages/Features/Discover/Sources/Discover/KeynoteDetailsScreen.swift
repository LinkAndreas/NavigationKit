import SwiftUI

public struct KeynoteDetailsScreen: View {
    let keynoteId: String
    
    public init(keynoteId: String) {
        self.keynoteId = keynoteId
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                ZStack(alignment: .bottomLeading) {
                    Rectangle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(height: 200)
                        .cornerRadius(16)
                        .overlay(
                            Image(systemName: iconFor(id: keynoteId))
                                .font(.system(size: 80))
                                .foregroundColor(.blue)
                        )
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(titleFor(id: keynoteId))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(subtitleFor(id: keynoteId))
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.blue)
                        Text("june_8_1000_am_1200_pm")
                            .font(.headline)
                    }
                    
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                        Text("steve_jobs_theater")
                            .font(.headline)
                    }
                    
                    Divider()
                    
                    Text("description")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top, 8)
                    
                    Text("this_keynote_will_cover_all_the_new_exci")
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("keynote_details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func titleFor(id: String) -> String {
        switch id {
        case "k1": return "State of the Union"
        case "k2": return "Swift in 2026"
        case "k3": return "UI Architecture"
        default: return "Keynote"
        }
    }
    
    private func subtitleFor(id: String) -> String {
        switch id {
        case "k1": return "Deep dive into new developer tools."
        case "k2": return "What's new in the Swift language."
        case "k3": return "Building scalable apps with SwiftUI."
        default: return ""
        }
    }
    
    private func iconFor(id: String) -> String {
        switch id {
        case "k1": return "hammer.fill"
        case "k2": return "swift"
        case "k3": return "rectangle.3.group.fill"
        default: return "applelogo"
        }
    }
}
