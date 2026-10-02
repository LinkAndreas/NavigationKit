import Foundation

/// A top-level section of a ``NavigationRoot``: a tab in compact width, a sidebar item in
/// regular width. Its id is what `Navigator.select(_:)` and `Step.select(_:)` refer to.
///
/// ```swift
/// RootSection(AppTab.schedule, "Schedule", icon: "calendar") {
///     ScheduleRoute.list
/// } detail: {
///     ScheduleRoute.placeholder   // the detail column in a split view
/// }
/// ```
///
/// A section can host a ``Flow``: its steps are the tab's screens, and finishing or cancelling it
/// starts it over in a fresh run — a "New order" tab is ready for the next order:
///
/// ```swift
/// RootSection(AppTab.order, "Order", icon: "cart", flow: Checkout()) { order in
///     receipts.add(order)
/// }
/// ```
///
/// Roots are `any Route`, so sections can come from data whose tabs use different route types:
///
/// ```swift
/// for tab in tabs {
///     RootSection(tab.id, tab.title, icon: tab.icon) { tab.route }   // tab.route: any Route
/// }
/// ```
public struct RootSection {
    let id: AnySectionID
    let title: LocalizedStringResource
    let icon: String?
    let root: AnyRoute
    let detail: AnyRoute?
    /// Called with the result when a flow at the section's root finishes.
    let onFlowFinish: (@MainActor (any Sendable) -> Void)?

    public init<ID: Hashable & Sendable>(
        _ id: ID,
        _ title: LocalizedStringResource,
        icon: String? = nil,
        root: () -> any Route
    ) {
        self.init(id: AnySectionID(id), title: title, icon: icon, root: AnyRoute(root()), detail: nil)
    }

    public init<ID: Hashable & Sendable>(
        _ id: ID,
        _ title: LocalizedStringResource,
        icon: String? = nil,
        root: () -> any Route,
        detail: () -> any Route
    ) {
        self.init(id: AnySectionID(id), title: title, icon: icon, root: AnyRoute(root()), detail: AnyRoute(detail()))
    }

    /// A section that hosts `flow`. When the flow finishes, `onFinish` gets its result and the
    /// flow starts over; cancelling it starts it over without calling `onFinish`.
    public init<ID: Hashable & Sendable, F: Flow>(
        _ id: ID,
        _ title: LocalizedStringResource,
        icon: String? = nil,
        flow: F,
        onFinish: (@MainActor (F.Result) -> Void)? = nil
    ) {
        var handler: (@MainActor (any Sendable) -> Void)?
        if let onFinish {
            handler = { value in
                if let result = value as? F.Result { onFinish(result) }
            }
        }
        self.init(id: AnySectionID(id), title: title, icon: icon, root: AnyRoute(flow), detail: nil, onFlowFinish: handler)
    }

    init(
        id: AnySectionID,
        title: LocalizedStringResource,
        icon: String?,
        root: AnyRoute,
        detail: AnyRoute?,
        onFlowFinish: (@MainActor (any Sendable) -> Void)? = nil
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.root = root
        self.detail = detail
        self.onFlowFinish = onFlowFinish
    }
}

@resultBuilder
public enum RootSectionsBuilder {
    public static func buildExpression(_ section: RootSection) -> [RootSection] { [section] }
    public static func buildExpression(_ sections: [RootSection]) -> [RootSection] { sections }
    public static func buildBlock(_ parts: [RootSection]...) -> [RootSection] { parts.flatMap { $0 } }
    public static func buildOptional(_ part: [RootSection]?) -> [RootSection] { part ?? [] }
    public static func buildEither(first: [RootSection]) -> [RootSection] { first }
    public static func buildEither(second: [RootSection]) -> [RootSection] { second }
    public static func buildArray(_ parts: [[RootSection]]) -> [RootSection] { parts.flatMap { $0 } }
}

/// The layout a ``NavigationRoot`` renders its sections in.
public enum NavigationLayout: Hashable, Sendable {
    /// Only the selected section's stack. The default for a single root.
    case stack
    case tabs
    case split
    /// Tabs in compact width, sidebar + detail in regular width; follows size-class changes.
    case adaptive
}
