import Foundation

/// A destination in your app, described as a plain value.
///
/// Routes are typically one enum per feature. Conforming to `Codable` is what makes navigation
/// state restorable across launches and shareable via Handoff; for enums with `String`/`Int`
/// payloads the compiler synthesizes it for you.
///
/// Routes can declare *traits* that change how generic actions such as ``Navigator/open(_:)``
/// treat them, so call sites stay a single verb:
///
/// ```swift
/// enum SpeakersRoute: Route {
///     case overview, detail(id: String), contact(email: String)
///
///     var presentation: PresentationStyle? {
///         if case .contact = self { .sheet(detents: [.medium, .large]) } else { nil }
///     }
/// }
/// ```
public protocol Route: Hashable, Codable, Sendable {
    /// A stable identifier used to encode and decode this route type.
    /// Defaults to the module-qualified type name. Override it to survive type renames.
    static var routeKey: String { get }

    /// How ``Navigator/open(_:)`` and ``Navigator/present(_:as:)`` show this route when the
    /// caller doesn't specify a style. `nil` (the default) means "push".
    var presentation: PresentationStyle? { get }

    /// When `true`, navigating to this route first runs the app's auth gate.
    var requiresAuth: Bool { get }

    /// When `true`, the tab bar is hidden while this route is on screen.
    var hidesTabBar: Bool { get }
}

public extension Route {
    static var routeKey: String { String(reflecting: Self.self) }
    var presentation: PresentationStyle? { nil }
    var requiresAuth: Bool { false }
    var hidesTabBar: Bool { false }
}
