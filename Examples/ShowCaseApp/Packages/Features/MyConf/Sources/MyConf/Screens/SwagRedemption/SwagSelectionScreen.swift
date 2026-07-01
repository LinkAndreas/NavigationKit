import SwiftUI

public struct SwagSelectionScreen: View {
    let onNextTapped: () -> Void

    public var body: some View {
        VStack(spacing: 20) {
            Text("Reward Selection").font(.title)
            Button("Next: Reward Collector Selection", action: onNextTapped)
        }
        .padding()
        .navigationTitle("Rewards")
    }
}

