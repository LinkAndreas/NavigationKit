import NavigationKit
import SwiftUI

struct OverviewScreen: View {
    let onSpeakerTapped: (String) -> Void

    let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]
    
    @State private var selectedBadge: String? = nil
    
    private var allBadges: [String] {
        let all = SpeakerMock.speakers.flatMap { $0.badges }
        return Array(Set(all)).sorted()
    }
    
    private var filteredSpeakers: [Speaker] {
        guard let selectedBadge else { return SpeakerMock.speakers }
        return SpeakerMock.speakers.filter { $0.badges.contains(selectedBadge) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Badge Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterBadge(title: "All", isSelected: selectedBadge == nil) {
                            withAnimation { selectedBadge = nil }
                        }
                        
                        ForEach(allBadges, id: \.self) { badge in
                            FilterBadge(title: badge, isSelected: selectedBadge == badge) {
                                withAnimation { selectedBadge = badge }
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Speakers Grid
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(filteredSpeakers) { speaker in
                        Button(action: { onSpeakerTapped(speaker.id) }) {
                            VStack {
                                Image(speaker.imageName, bundle: .module)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                                    .foregroundColor(.blue)
                                    .padding(.top, 16)
                                
                                VStack(spacing: 4) {
                                    Text(speaker.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                        .multilineTextAlignment(.center)
                                    
                                    Text(speaker.company)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.bottom, 16)
                            }
                            .frame(maxWidth: .infinity)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(16)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("speakers")
    }
}
