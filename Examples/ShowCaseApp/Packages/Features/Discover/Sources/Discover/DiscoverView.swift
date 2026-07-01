import SwiftUI

struct DiscoverView: View {
    let openEventDetails: () -> Void
    let openKeynoteDetails: (String) -> Void
    let openSchedule: () -> Void
    let openAccount: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Hero Banner
                Button(action: openEventDetails) {
                    ZStack(alignment: .bottomLeading) {
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(height: 220)
                        .cornerRadius(20)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("WWDC 2026")
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                                .foregroundColor(.white)
                                .fontDesign(.rounded)
                            
                            Text("The future of iOS starts here.")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding()
                    }
                    .padding(.horizontal)
                }
                .buttonStyle(.plain)
                
                // Horizontal Carousel
                VStack(alignment: .leading, spacing: 12) {
                    Text("Featured Keynotes")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    let keynotes = [
                        (id: "k1", title: "State of the Union", subtitle: "Deep dive into new developer tools.", icon: "hammer.fill"),
                        (id: "k2", title: "Swift in 2026", subtitle: "What's new in the Swift language.", icon: "swift"),
                        (id: "k3", title: "UI Architecture", subtitle: "Building scalable apps with SwiftUI.", icon: "rectangle.3.group.fill")
                    ]
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(keynotes, id: \.id) { keynote in
                                Button(action: { openKeynoteDetails(keynote.id) }) {
                                    VStack(alignment: .leading) {
                                        Rectangle()
                                            .fill(Color.blue.opacity(0.2))
                                            .frame(width: 260, height: 140)
                                            .cornerRadius(12)
                                            .overlay(
                                                Image(systemName: keynote.icon)
                                                    .font(.largeTitle)
                                                    .foregroundColor(.blue)
                                            )
                                        
                                        Text(keynote.title)
                                            .font(.headline)
                                        Text(keynote.subtitle)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(width: 260)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Quick Actions
                VStack(spacing: 12) {
                    Button(action: openSchedule) {
                        HStack {
                            Image(systemName: "calendar")
                            Text("Browse Full Schedule")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    
                    Button(action: openAccount) {
                        HStack {
                            Image(systemName: "person.crop.circle")
                            Text("My Profile & Settings")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                .buttonStyle(.plain)
            }
            .padding(.vertical)
        }
        .navigationTitle("Discover")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: openAccount) {
                    Image(systemName: "person.crop.circle")
                }
            }
        }
    }
}
