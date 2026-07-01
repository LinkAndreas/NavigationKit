import SwiftUI

/// A registry that binds route data models to their corresponding SwiftUI Views.
///
/// `RouteBuilder` holds the factory closures that construct views for any registered `Hashable` route.
/// The `NavigationContainer` uses this registry to dynamically resolve a UI for an `AnyRoute` at runtime.
///
/// **Example Usage:**
/// ```swift
/// let registry = RouteBuilder()
/// registry.register(SettingsRoute.self) { route, navigator in
///     SettingsView(navigator: navigator)
/// }
/// ```
@MainActor
public final class RouteBuilder {
    private var builders: [ObjectIdentifier: (AnyRoute, StackNavigator) -> AnyView] = [:]

    /// Creates a new, empty route registry.
    public init() {}

    /// Registers a view builder for a specific route type.
    ///
    /// - Parameters:
    ///   - type: The `Hashable` route type to register (e.g., `ProfileRoute.self`).
    ///   - build: A closure that takes the route instance and the owning `StackNavigator`, and returns a `View`.
    public func register<R: Hashable, V: View>(
        _ type: R.Type, @ViewBuilder _ build: @escaping (R, StackNavigator) -> V
    ) {
        builders[ObjectIdentifier(type)] = { any, nav in
            guard let r = any.wrapped.base as? R else { return AnyView(EmptyView()) }
            return AnyView(build(r, nav))
        }
    }

    /// Resolves and builds the view for a type-erased route.
    ///
    /// - Parameters:
    ///   - route: The `AnyRoute` representing the data for the destination.
    ///   - navigator: The `StackNavigator` instance managing this route.
    /// - Returns: An `AnyView` containing the built UI, or a red error text view if unregistered.
    func view(for route: AnyRoute, navigator: StackNavigator) -> AnyView {
        builders[route.typeID]?(route, navigator)
            ?? AnyView(Text("⚠️ Unregistered route: \(String(describing: route.wrapped))")
                        .foregroundStyle(.red))
    }
}
