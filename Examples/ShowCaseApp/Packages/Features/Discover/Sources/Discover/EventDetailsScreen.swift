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
                    Text("wwdc_2026")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("cupertino_california")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.purple)
                        Text("june_8_june_12_2026")
                            .font(.headline)
                    }
                    
                    HStack {
                        Image(systemName: "ticket.fill")
                            .foregroundColor(.purple)
                        Text("registration_open")
                            .font(.headline)
                    }
                    
                    Divider()
                    
                    Text("about_the_event")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top, 8)
                    
                    Text("join_developers_from_around_the_world_fo")
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("event_details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

