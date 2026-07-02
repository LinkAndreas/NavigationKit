import SwiftUI

public struct RepositoryLinkEntryScreen: View {
    let flow: ProofRequirement
    let onNextTapped: () -> Void

    public var body: some View {
        VStack(spacing: 20) {
            Text("service_provider_form").font(.title)
            Text("flow_flow").font(.subheadline)
            Button("next_summary", action: onNextTapped)
        }
        .padding()
        .navigationTitle("service_provider")
    }
}

