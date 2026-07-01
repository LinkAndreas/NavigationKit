import SwiftUI
import MapKit

public struct EventDetailsScreen: View {
    @State private var position: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.3346, longitude: -122.0090), // Apple Park
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    ))

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Map(position: $position) {
                    Marker("Apple Park", coordinate: CLLocationCoordinate2D(latitude: 37.3346, longitude: -122.0090))
                        .tint(.purple)
                }
                .frame(height: 250)
                .cornerRadius(16)
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("WWDC 2026")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Cupertino, California")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.purple)
                        Text("June 8 - June 12, 2026")
                            .font(.headline)
                    }
                    
                    HStack {
                        Image(systemName: "ticket.fill")
                            .foregroundColor(.purple)
                        Text("Registration Open")
                            .font(.headline)
                    }
                    
                    Divider()
                    
                    Text("About the Event")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top, 8)
                    
                    Text("Join developers from around the world for an exhilarating week of technology and innovation. Get a first look at Apple’s latest software, learn from Apple engineers, and connect with the global developer community.")
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Event Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

