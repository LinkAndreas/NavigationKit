import SwiftUI

public struct OverviewScreen: View {
    let onScanQRCodeTapped: () -> Void
    let onSavedSessionsTapped: () -> Void

    public var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Glassmorphic Ticket Pass
                ZStack {
                    LinearGradient(
                        colors: [.blue.opacity(0.8), .purple.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    VStack(spacing: 16) {
                        HStack {
                            Text("WWDC 2026")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "applelogo")
                                .foregroundColor(.white)
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.5))
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Attendee")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                Text("Andreas Link")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            Image(systemName: "qrcode")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(24)
                    .background(.ultraThinMaterial)
                }
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Actions
                VStack(spacing: 16) {
                    Button(action: onSavedSessionsTapped) {
                        HStack {
                            Image(systemName: "bookmark.fill")
                            Text("My Saved Sessions")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    
                    Button(action: onScanQRCodeTapped) {
                        HStack {
                            Image(systemName: "qrcode.viewfinder")
                            Text("Scan QR Code")
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
        }
        .navigationTitle("MyConf")
    }
}
