import SwiftUI

public struct HackathonRegistrationSummaryScreen: View {
    let onBackToDashboardTapped: () -> Void

    public var body: some View {
        VStack(spacing: 20) {
            Text("Activity Submission Summary").font(.title)
            Button("Back to Dashboard", action: onBackToDashboardTapped)
        }
        .padding()
        .navigationTitle("Summary")
    }
}
