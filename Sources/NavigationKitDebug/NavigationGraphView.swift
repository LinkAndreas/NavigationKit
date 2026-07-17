import NavigationKit

import SwiftUI

/// Renders a live snapshot of the navigator tree.
///
/// Shared by both platforms' debuggers: iOS presents it in a sheet, macOS in its own window.
struct NavigationGraphView: View {
    let navigator: RootNavigator

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            Text(navigator.debugDescription)
                .font(.system(.body, design: .monospaced))
                .fixedSize(horizontal: true, vertical: false)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
    }
}
