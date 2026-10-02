import SwiftUI

public struct HackathonRegistrationSummaryScreen: View {
    let proof: Proof
    let onBackToDashboardTapped: () -> Void

    public var body: some View {
        VStack(spacing: 20) {
            Text("activity_submission_summary").font(.title)
            Text("flow_flow \(proof.description)").font(.subheadline)
            Button("back_to_dashboard", action: onBackToDashboardTapped)
        }
        .padding()
        .navigationTitle("summary")
    }
}
