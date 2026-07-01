import SwiftUI

/// A SwiftUI View that renders a `RootNavigator` into an actual UI hierarchy.
///
/// `NavigationContainer` acts as the root driver for your app's navigation tree.
/// By switching on the provided `RootNavigator` (`.stack`, `.tabs`, or `.split`),
/// it delegates rendering to the matching container view.
///
/// **Example Usage:**
/// ```swift
/// var body: some View {
///     NavigationContainer(
///         navigator: appNavigator,
///         routeBuilder: routeBuilder
///     )
/// }
/// ```
@MainActor
public struct NavigationContainer: View {
    private let navigator: RootNavigator
    private let routeBuilder: RouteBuilder

    /// Creates a new navigation context.
    ///
    /// - Parameters:
    ///   - navigator: The navigator managing the navigation paths and modals.
    ///   - routeBuilder: The registry capable of converting route data models into `AnyView`.
    public init(navigator: RootNavigator, routeBuilder: RouteBuilder) {
        self.navigator = navigator
        self.routeBuilder = routeBuilder
    }

    public var body: some View {
        switch navigator {
        case let .stack(navigator):
            StackContainer(
                navigator: navigator,
                routeBuilder: routeBuilder
            )
        case let .tabs(navigator):
            TabsContainer(
                navigator: navigator,
                routeBuilder: routeBuilder
            )
        case let .split(navigator):
            SplitContainer(
                navigator: navigator,
                routeBuilder: routeBuilder
            )
        }
    }
}
