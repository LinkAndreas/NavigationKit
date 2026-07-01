import SwiftUI

public struct ProjectCategorySelectionScreen: View {
    let onNextTapped: () -> Void

    public var body: some View {
        VStack(spacing: 20) {
            Text("Activity Selection").font(.title)
            Button("Next: Additional Register Form", action: onNextTapped)
        }
        .padding()
        .navigationTitle("Activities")
    }
}

