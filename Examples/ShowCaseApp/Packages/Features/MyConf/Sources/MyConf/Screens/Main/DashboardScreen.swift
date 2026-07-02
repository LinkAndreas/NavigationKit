import SwiftUI

public struct DashboardScreen: View {
    let onApplyForRewardTapped: () -> Void
    let onSubmitActivityTapped: () -> Void

    public var body: some View {
        VStack(spacing: 20) {
            Text("dashboard").font(.title)
            Button("apply_for_reward", action: onApplyForRewardTapped)
            Button("submit_activity", action: onSubmitActivityTapped)
        }
        .padding()
        .navigationTitle("dashboard")
    }
}

