import SwiftUI

public struct ParticipationStatementScreen: View {
    let onJoinTapped: () -> Void

    public var body: some View {
        VStack(spacing: 20) {
            Text("participation_statement").font(.title)
            Button("join", action: onJoinTapped)
        }
        .padding()
        .navigationTitle("participation")
    }
}

