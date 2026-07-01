import SwiftUI

public struct ParticipationStatementScreen: View {
    let onJoinTapped: () -> Void

    public var body: some View {
        VStack(spacing: 20) {
            Text("Participation Statement").font(.title)
            Button("Join", action: onJoinTapped)
        }
        .padding()
        .navigationTitle("Participation")
    }
}

