import SwiftUI

public struct ProjectUploadScreen: View {
    let flow: ProofRequirement
    let onNextTapped: () -> Void

    public var body: some View {
        VStack(spacing: 20) {
            Text("Document Selection").font(.title)
            Text("Flow: \(flow.rawValue)").font(.subheadline)
            Button(flow == .both ? "Next: Service Provider" : "Next: Summary", action: onNextTapped)
        }
        .padding()
        .navigationTitle("Documents")
    }
}

