import Foundation

/// How long a value passed to ``Navigator/remember(for:_:)`` is kept.
///
/// | Lifetime | Released when |
/// |---|---|
/// | ``screen`` | the screen leaves its stack (popped, dismissed, replaced) |
/// | ``flow`` | the innermost running flow finishes, is cancelled or backed out of |
/// | ``flow(_:)`` | that specific enclosing flow ends — reachable from inside nested flows |
/// | ``window`` | the `NavigationRoot` goes away (normally one per window) |
///
/// Outside a flow, ``flow`` and ``flow(_:)`` fall back to ``screen``.
public struct Lifetime: Hashable, Sendable, CustomStringConvertible {
    package enum Kind: Hashable, Sendable {
        case screen
        /// The innermost flow, or the innermost flow whose route key matches.
        case flow(routeKey: String?)
        case window
    }

    package let kind: Kind

    /// This screen, while it's on its stack.
    public static let screen = Lifetime(kind: .screen)

    /// One run of the innermost flow containing this screen.
    public static let flow = Lifetime(kind: .flow(routeKey: nil))

    /// One run of the innermost enclosing flow of type `F` — for example the outer flow, from a
    /// step of a flow nested inside it.
    public static func flow<F: Flow>(_: F.Type) -> Lifetime {
        Lifetime(kind: .flow(routeKey: F.routeKey))
    }

    /// The `NavigationRoot` — normally one per window.
    public static let window = Lifetime(kind: .window)

    public var description: String {
        switch kind {
        case .screen: ".screen"
        case .flow(nil): ".flow"
        case let .flow(key?): ".flow(\(key))"
        case .window: ".window"
        }
    }
}
