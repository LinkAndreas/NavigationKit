import SwiftUI

public struct ProjectCategorySelectionScreen: View {
    let onNextTapped: () -> Void

    public var body: some View {
        VStack(spacing: 20) {
            Text("activity_selection").font(.title)
            Button("next_additional_register_form", action: onNextTapped)
        }
        .padding()
        .navigationTitle("activities")
    }
}

