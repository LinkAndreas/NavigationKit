import SwiftUI

/// Identifies the screen a view belongs to, so modifiers like `navigationGuard` can attach to it.
struct ScreenContext {
    let stack: StackNode
    let entryID: UUID
    let isRoot: Bool
}

public extension EnvironmentValues {
    /// The navigator scoped to the current screen. Prefer receiving it explicitly (through
    /// `ViewRoute.body(_:)` or a registry closure); the environment is handy deep in a view tree.
    @Entry var navigator: any Navigator = UnavailableNavigator()

    /// The store of the enclosing ``NavigationRoot``.
    @Entry var navigationStore: NavigationStore? = nil
}

extension EnvironmentValues {
    @Entry var screenContext: ScreenContext? = nil
    @Entry var routeRegistry: RouteRegistry? = nil
    @Entry var navigationZoomNamespace: Namespace.ID? = nil
}
