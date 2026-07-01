import SwiftUI

public struct TeamDetailsFormScreen: View {
    let onDocumentFlowTapped: () -> Void
    let onServiceProviderFlowTapped: () -> Void
    let onDocumentOrServiceProviderFlowTapped: () -> Void
    let onDocumentAndServiceProviderFlowTapped: () -> Void

    public var body: some View {
        VStack(spacing: 20) {
            Text("Additional Register Form").font(.title)
            Button("Document Form Flow", action: onDocumentFlowTapped)
            Button("Service Provider Form Flow", action: onServiceProviderFlowTapped)
            Button("Document OR Service Provider Flow", action: onDocumentOrServiceProviderFlowTapped)
            Button("Document AND Service Provider Flow", action: onDocumentAndServiceProviderFlowTapped)
        }
        .padding()
        .navigationTitle("Additional Register")
    }
}

