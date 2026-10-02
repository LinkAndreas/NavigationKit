import Foundation

/// One step of a navigation path. A list of steps describes *where to go* independently of the
/// layout, so the same path works with tabs, a sidebar, or a single stack. Deep links,
/// ``Navigator/navigate(_:)`` and `NavigationStore/currentSteps` all speak this language.
///
/// ```swift
/// navigator.navigate([
///     .select(AppTab.schedule),
///     .push(ScheduleRoute.session(id: "42")),
/// ])
/// ```
public enum Step: Hashable, Sendable, CustomStringConvertible {
    /// Select a top-level section and reset it to its root.
    case select(section: AnySectionID)
    /// Push onto the current stack.
    case push(route: AnyRoute)
    /// Present modally; subsequent steps apply inside the presented stack.
    case present(route: AnyRoute, style: PresentationStyle)
    /// Show in the detail column when there is one, otherwise push.
    case show(route: AnyRoute)

    public static func select<ID: Hashable & Sendable>(_ id: ID) -> Step { .select(section: AnySectionID(id)) }
    public static func push<R: Route>(_ route: R) -> Step { .push(route: AnyRoute(route)) }
    public static func present<R: Route>(_ route: R, as style: PresentationStyle? = nil) -> Step {
        .present(route: AnyRoute(route), style: style ?? route.presentation ?? .sheet)
    }
    public static func show<R: Route>(_ route: R) -> Step { .show(route: AnyRoute(route)) }

    public var description: String {
        switch self {
        case let .select(id): ".select(\(id))"
        case let .push(route): ".push(\(route))"
        case let .present(route, style): ".present(\(route), \(style))"
        case let .show(route): ".show(\(route))"
        }
    }
}
