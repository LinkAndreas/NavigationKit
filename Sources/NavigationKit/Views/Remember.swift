import SwiftUI

/// Keeps a value for a ``Lifetime`` and passes it to its content — the view form of
/// ``Navigator/remember(for:_:)``.
///
/// ```swift
/// case .review:
///     Remember(for: .flow) { CheckoutSession() } content: { session in
///         ReviewScreen(session: session, onNext: { nav.push(.payment) })
///     }
/// ```
///
/// Wrappers nest, so the composition is visible where screens are wired:
///
/// ```swift
/// Remember(for: .window) { CheckoutAPI() } content: { api in
///     Remember(for: .flow) { CheckoutSession(api: api) } content: { session in
///         ReviewScreen(session: session)
///     }
/// }
/// ```
///
/// The value follows the same rules as `remember(for:)`: created the first time it's asked for,
/// the same value on every later render, released when the lifetime ends. It uses the navigator
/// of the screen it's in, so it keeps values inside screens NavigationKit shows; elsewhere (a bare
/// preview) `make` runs on every render.
public struct Remember<Value, Content: View>: View {
    private let lifetime: Lifetime
    private let make: () -> Value
    private let content: (Value) -> Content
    @Environment(\.navigator) private var navigator

    public init(
        for lifetime: Lifetime,
        make: @escaping () -> Value,
        @ViewBuilder content: @escaping (Value) -> Content
    ) {
        self.lifetime = lifetime
        self.make = make
        self.content = content
    }

    public var body: some View {
        content(navigator.remember(for: lifetime, make))
    }
}
