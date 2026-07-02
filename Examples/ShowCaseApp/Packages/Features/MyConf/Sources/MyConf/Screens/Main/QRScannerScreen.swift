import SwiftUI

public struct QRScannerScreen: View {
    let onDismissTapped: () -> Void
    
    public var body: some View {
        ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 32) {
                    Text("point_your_camera_at_a_qr_code")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ZStack {
                        Rectangle()
                            .stroke(Color.blue, lineWidth: 4)
                            .frame(width: 250, height: 250)
                            .cornerRadius(12)
                        
                        Image(systemName: "qrcode.viewfinder")
                            .resizable()
                            .frame(width: 200, height: 200)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    
                    Spacer()
                }
                .padding(.top, 40)
            }
            .navigationTitle("scan_qr_code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel", action: onDismissTapped)
                        .foregroundColor(.white)
                }
            }
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
