import SwiftUI

public struct TeamDetailsFormScreen: View {
    let onDocumentFlowTapped: () -> Void
    let onServiceProviderFlowTapped: () -> Void
    let onDocumentOrServiceProviderFlowTapped: () -> Void
    let onDocumentAndServiceProviderFlowTapped: () -> Void

    public var body: some View {
        VStack(spacing: 20) {
            Text("additional_register_form").font(.title)
            Button("document_form_flow", action: onDocumentFlowTapped)
            Button("service_provider_form_flow", action: onServiceProviderFlowTapped)
            Button("document_or_service_provider_flow", action: onDocumentOrServiceProviderFlowTapped)
            Button("document_and_service_provider_flow", action: onDocumentAndServiceProviderFlowTapped)
        }
        .padding()
        .navigationTitle("additional_register")
    }
}

