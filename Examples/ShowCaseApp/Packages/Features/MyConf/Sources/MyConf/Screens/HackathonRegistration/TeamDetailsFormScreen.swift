import SwiftUI

public struct TeamDetailsFormScreen: View {
    let onProofRequirementSelected: (ProofRequirement) -> Void

    public var body: some View {
        VStack(spacing: 20) {
            Text("additional_register_form").font(.title)
            Button("document_form_flow") { onProofRequirementSelected(.documentOnly) }
            Button("service_provider_form_flow") { onProofRequirementSelected(.serviceProviderOnly) }
            Button("document_or_service_provider_flow") { onProofRequirementSelected(.either) }
            Button("document_and_service_provider_flow") { onProofRequirementSelected(.both) }
        }
        .padding()
        .navigationTitle("additional_register")
    }
}
