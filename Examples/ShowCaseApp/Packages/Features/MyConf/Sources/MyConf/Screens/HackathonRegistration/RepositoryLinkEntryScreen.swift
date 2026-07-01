import SwiftUI

public struct RepositoryLinkEntryScreen: View {
    let flow: ProofRequirement
    let onNextTapped: () -> Void

    public var body: some View {
        VStack(spacing: 20) {
            Text("Service Provider Form").font(.title)
            Text("Flow: \(flow.rawValue)").font(.subheadline)
            Button("Next: Summary", action: onNextTapped)
        }
        .padding()
        .navigationTitle("Service Provider")
    }
}

