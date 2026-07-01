import NavigationKit
import SwiftUI

public struct DebuggerWindowModifier: ViewModifier {
    let navigator: RootNavigator
    @State private var manager = DebuggerWindowManager()

    public init(navigator: RootNavigator) {
        self.navigator = navigator
    }

    public func body(content: Content) -> some View {
        content
            .onAppear {
                manager.show(navigator: navigator)
            }
    }
}

extension View {
    public func withNavigationGraphDebuggerWindow(navigator: RootNavigator) -> some View {
        self.modifier(DebuggerWindowModifier(navigator: navigator))
    }
}
