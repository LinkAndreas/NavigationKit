import SwiftUI

public struct TeamSizeSelectionScreen: View {
    let onProjectCategorySelectionTapped: () -> Void
    let onCancellationTapped: () -> Void

    public var body: some View {
        VStack(spacing: 20) {
            Text("Group Selection").font(.title)
            Button("Next: Activity Selection", action: onProjectCategorySelectionTapped)
            Button("Cancellation", action: onCancellationTapped)
        }
        .padding()
        .navigationTitle("Groups")
    }
}

