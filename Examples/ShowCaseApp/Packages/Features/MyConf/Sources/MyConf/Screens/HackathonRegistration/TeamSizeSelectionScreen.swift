import SwiftUI

public struct TeamSizeSelectionScreen: View {
    let onProjectCategorySelectionTapped: () -> Void
    let onCancellationTapped: () -> Void

    public var body: some View {
        VStack(spacing: 20) {
            Text("group_selection").font(.title)
            Button("next_activity_selection", action: onProjectCategorySelectionTapped)
            Button("cancellation", action: onCancellationTapped)
        }
        .padding()
        .navigationTitle("groups")
    }
}

