import SwiftUI

public struct DashboardScreen: View {
    let onApplyForRewardTapped: () -> Void
    let onSubmitActivityTapped: () -> Void

    public var body: some View {
        VStack(spacing: 20) {
            Text("Dashboard").font(.title)
            Button("Apply for Reward", action: onApplyForRewardTapped)
            Button("Submit Activity", action: onSubmitActivityTapped)
        }
        .padding()
        .navigationTitle("Dashboard")
    }
}

