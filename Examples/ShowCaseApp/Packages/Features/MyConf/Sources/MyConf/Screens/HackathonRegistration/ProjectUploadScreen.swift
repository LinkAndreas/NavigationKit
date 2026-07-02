import SwiftUI

public struct ProjectUploadScreen: View {
    let flow: ProofRequirement
    let onNextTapped: () -> Void

    public var body: some View {
        VStack(spacing: 20) {
            Text("document_selection").font(.title)
            Text("flow_flow").font(.subheadline)
            Button(flow == .both ? "Next: Service Provider" : "Next: Summary", action: onNextTapped)
        }
        .padding()
        .navigationTitle("documents")
    }
}

