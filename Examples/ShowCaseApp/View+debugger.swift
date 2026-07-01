import SwiftUI
import NavigationKit

#if DEBUG
import NavigationKitDebug
#endif

extension View {
    @ViewBuilder
    func withOptionalNavigationGraphDebugger(navigator: RootNavigator) -> some View {
        #if DEBUG
        self
            .withNavigationGraphDebuggerWindow(navigator: navigator)
        #else
        self
        #endif
    }
}
