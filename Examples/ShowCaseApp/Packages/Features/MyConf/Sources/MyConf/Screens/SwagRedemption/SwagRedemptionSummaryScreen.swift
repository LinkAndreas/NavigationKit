import SwiftUI

public struct SwagRedemptionSummaryScreen: View {
    let onBackToDashboardTapped: () -> Void

    public var body: some View {
        VStack(spacing: 20) {
            Text("reward_summary").font(.title)
            Button("back_to_dashboard", action: onBackToDashboardTapped)
        }
        .padding()
        .navigationTitle("summary")
    }
}

