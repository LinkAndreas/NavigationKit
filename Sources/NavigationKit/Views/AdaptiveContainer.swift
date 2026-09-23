import SwiftUI

/// A private SwiftUI View that renders an `AdaptiveNavigator`.
///
/// `AdaptiveContainer` reads the horizontal size class where the whole window's width is
/// known — above the split view, whose columns each report compact — and shows the tab bar
/// or the split view to match. It presents the adaptive navigator's own modals outside the
/// switch, so they stay up while the layout underneath changes.
@MainActor
struct AdaptiveContainer: View {
    @Bindable var navigator: AdaptiveNavigator
    let routeBuilder: RouteBuilder

    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

    var body: some View {
        Group {
            // The navigator's layout once it has one, so a switch and the state its
            // `onLayoutChange` moves across arrive in the same update.
            switch navigator.layout ?? layoutForWidth {
            case .compact:
                TabsContainer(navigator: navigator.compact, routeBuilder: routeBuilder)
            case .regular:
                SplitContainer(navigator: navigator.regular, routeBuilder: routeBuilder)
            }
        }
        .onChange(of: layoutForWidth, initial: true) { _, layout in
            navigator.updateLayout(layout)
        }
        .alert(spec: $navigator.modals.alert)
        .alert(error: $navigator.modals.error, retry: navigator.modals.errorRetry)
        .confirmationDialog(spec: $navigator.modals.confirmationDialog)
        .sheet(item: $navigator.modals.sheet) { modalNavigator in
            NavigationContainer(navigator: .stack(modalNavigator), routeBuilder: routeBuilder)
        }
        .fullScreenCoverOrSheet(item: $navigator.modals.fullScreenCover) { modalNavigator in
            NavigationContainer(navigator: .stack(modalNavigator), routeBuilder: routeBuilder)
        }
    }

    /// The layout the window's width calls for. Tests `.regular`, so a missing size class
    /// gets the narrow layout.
    private var layoutForWidth: AdaptiveLayout {
        #if os(iOS)
        horizontalSizeClass == .regular ? .regular : .compact
        #else
        // A Mac window has no size class; it always has room for the split view.
        .regular
        #endif
    }
}
