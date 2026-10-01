import Foundation

/// Every navigation request a screen can make. ``Navigator`` conformers handle these;
/// the convenience API (`push`, `present`, …) builds them for you. Tests can assert on them
/// with `RecordingNavigator` from `NavigationKitTesting`.
public enum NavigationAction: Sendable, Equatable, CustomStringConvertible {
    case push(AnyRoute)
    /// Push or present according to the route's ``Route/presentation`` trait.
    case open(AnyRoute)
    case pop
    case popToRoot
    case popTo(AnyRoute)
    case present(AnyRoute, PresentationStyle?)
    case show(AnyRoute)
    case select(AnySectionID)
    case dismiss(result: (any Sendable)?)
    case flow(AnyRoute, PresentationStyle?)
    case finishFlow(result: (any Sendable)?)
    case navigate([Step])
    case openURL(URL)

    public static func == (lhs: NavigationAction, rhs: NavigationAction) -> Bool {
        switch (lhs, rhs) {
        case let (.push(a), .push(b)), let (.open(a), .open(b)), let (.popTo(a), .popTo(b)), let (.show(a), .show(b)):
            a == b
        case (.pop, .pop), (.popToRoot, .popToRoot):
            true
        case let (.present(a, s1), .present(b, s2)), let (.flow(a, s1), .flow(b, s2)):
            a == b && s1 == s2
        case let (.select(a), .select(b)):
            a == b
        case let (.dismiss(a), .dismiss(b)), let (.finishFlow(a), .finishFlow(b)):
            String(describing: a) == String(describing: b)
        case let (.navigate(a), .navigate(b)):
            a == b
        case let (.openURL(a), .openURL(b)):
            a == b
        default:
            false
        }
    }

    public var description: String {
        switch self {
        case let .push(r): "push(\(r))"
        case let .open(r): "open(\(r))"
        case .pop: "pop"
        case .popToRoot: "popToRoot"
        case let .popTo(r): "popTo(\(r))"
        case let .present(r, s): "present(\(r), \(s.map(\.description) ?? "default"))"
        case let .show(r): "show(\(r))"
        case let .select(id): "select(\(id))"
        case let .dismiss(result): "dismiss(\(result.map { "\($0)" } ?? "nil"))"
        case let .flow(r, s): "flow(\(r), \(s.map(\.description) ?? "push"))"
        case let .finishFlow(result): "finishFlow(\(result.map { "\($0)" } ?? "nil"))"
        case let .navigate(steps): "navigate(\(steps))"
        case let .openURL(url): "openURL(\(url))"
        }
    }

    /// The route this action navigates to, if any.
    public var targetRoute: AnyRoute? {
        switch self {
        case let .push(r), let .open(r), let .present(r, _), let .show(r), let .flow(r, _): r
        default: nil
        }
    }
}
