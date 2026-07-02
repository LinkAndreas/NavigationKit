import SwiftUI

public struct VerificationSelectionScreen: View {
    let onDocumentTapped: () -> Void
    let onServiceProviderTapped: () -> Void

    public var body: some View {
        VStack(spacing: 20) {
            Text("proof_selection").font(.title)
            Button("document_selection", action: onDocumentTapped)
            Button("service_provider_form", action: onServiceProviderTapped)
        }
        .padding()
        .navigationTitle("proofs")
    }
}

