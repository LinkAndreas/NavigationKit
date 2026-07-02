import SwiftUI

public struct SwagSelectionScreen: View {
    let onNextTapped: () -> Void

    public var body: some View {
        VStack(spacing: 20) {
            Text("reward_selection").font(.title)
            Button("next_reward_collector_selection", action: onNextTapped)
        }
        .padding()
        .navigationTitle("rewards")
    }
}

