import Foundation

/// A registry that converts inbound URLs into a `NavigationState`.
///
/// `DeeplinkResolver` allows various feature modules to register handlers that attempt to
/// parse a given `URL`. The first handler that successfully returns a valid `NavigationState`
/// will handle the deep link.
///
/// **Example Usage:**
/// ```swift
/// let resolver = DeeplinkResolver()
/// resolver.register { url in
///     guard url.host == "profile" else { return nil }
///     return .stack(StackState(path: [AnyRoute(ProfileRoute())]))
/// }
///
/// if let state = resolver.resolve(URL(string: "myapp://profile")!) {
///     applyDeepLink(state, to: navigator)
/// }
/// ```
@MainActor
public final class DeeplinkResolver {
    /// A list of registered URL parsers.
    private var handlers: [(URL) -> NavigationState?] = []

    /// Creates a new, empty deep link resolver.
    public init() {}

    /// Registers a new deep link handler.
    ///
    /// Handlers are evaluated in the order they were registered. The first handler to return
    /// a non-nil `NavigationState` wins.
    ///
    /// - Parameter handler: A closure that takes a `URL` and optionally returns a `NavigationState`.
    public func register(_ handler: @escaping (URL) -> NavigationState?) {
        handlers.append(handler)
    }
    
    /// Attempts to resolve a URL into a `NavigationState` using the registered handlers.
    ///
    /// - Parameter url: The URL to resolve.
    /// - Returns: The resolved `NavigationState`, or `nil` if no handler could process the URL.
    public func resolve(_ url: URL) -> NavigationState? {
        for handler in handlers {
            if let navigationState = handler(url) {
                return navigationState
            }
        }

        return nil
    }
}
