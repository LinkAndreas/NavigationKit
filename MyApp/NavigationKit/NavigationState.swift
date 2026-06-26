import SwiftUI

/// Declarative snapshot of one navigation context. Recursive via `modal`.
public struct NavigationState {
    public var root: AnyRoute
    public var path: [AnyRoute]
    public var modal: Modal?

    public indirect enum Modal {
        case sheet(NavigationState)
        case fullScreenCover(NavigationState)
    }

    public init<R: Hashable>(root: R, path: [AnyRoute] = [], modal: Modal? = nil) {
        self.root = AnyRoute(root); self.path = path; self.modal = modal
    }

    // Fluent builders so deep-link construction reads top-to-bottom.
    public func pushing<R: Hashable>(_ route: R) -> Self {
        var c = self; c.path.append(AnyRoute(route)); return c
    }
    public func pushing<R: Hashable>(all routes: [R]) -> Self {
        var c = self
        c.path.append(contentsOf: routes.map { AnyRoute($0) })
        return c
    }
    public func presentingSheet(_ s: NavigationState) -> Self {
        var c = self; c.modal = .sheet(s); return c
    }
    public func presentingCover(_ s: NavigationState) -> Self {
        var c = self; c.modal = .fullScreenCover(s); return c
    }
}
