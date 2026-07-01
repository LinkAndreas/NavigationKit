import SwiftUI

public struct VerificationSelectionScreen: View {
    let onDocumentTapped: () -> Void
    let onServiceProviderTapped: () -> Void

    public var body: some View {
        VStack(spacing: 20) {
            Text("Proof Selection").font(.title)
            Button("Document Selection", action: onDocumentTapped)
            Button("Service Provider Form", action: onServiceProviderTapped)
        }
        .padding()
        .navigationTitle("Proofs")
    }
}

