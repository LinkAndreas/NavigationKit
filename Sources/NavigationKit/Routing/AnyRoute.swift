import Foundation

/// A type-erased wrapper for route models, enabling generic storage and comparison in navigation stacks.
///
/// `AnyRoute` wraps any `Hashable` route and allows `NavigationKit` to manage heterogeneous routes
/// inside an array (e.g., `[AnyRoute]`) while retaining equality and hashing capabilities.
///
/// **Example Usage:**
/// ```swift
/// let userRoute = UserProfileRoute(id: "123")
/// let settingsRoute = SettingsRoute()
///
/// var path: [AnyRoute] = [
///     AnyRoute(userRoute),
///     AnyRoute(settingsRoute)
/// ]
/// ```
public struct AnyRoute: Hashable {
    /// The underlying type-erased route.
    public let wrapped: AnyHashable
    
    /// The unique identifier representing the underlying route's concrete type.
    let typeID: ObjectIdentifier

    /// Creates a type-erased route that wraps the given instance.
    ///
    /// - Parameter route: The concrete `Hashable` route to wrap.
    public init<R: Hashable>(_ route: R) {
        self.wrapped = AnyHashable(route)
        self.typeID = ObjectIdentifier(R.self)
    }
    
    /// Compares two type-erased routes for equality based on their wrapped instances.
    public static func == (l: Self, r: Self) -> Bool { l.wrapped == r.wrapped }

    /// Hashes the essential components of the route by passing them into the given hasher.
    public func hash(into h: inout Hasher) { h.combine(wrapped) }
}
