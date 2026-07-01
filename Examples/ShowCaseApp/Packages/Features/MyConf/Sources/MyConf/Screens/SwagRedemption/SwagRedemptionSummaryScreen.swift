import SwiftUI

public struct SwagRedemptionSummaryScreen: View {
    let onBackToDashboardTapped: () -> Void

    public var body: some View {
        VStack(spacing: 20) {
            Text("Reward Summary").font(.title)
            Button("Back to Dashboard", action: onBackToDashboardTapped)
        }
        .padding()
        .navigationTitle("Summary")
    }
}

