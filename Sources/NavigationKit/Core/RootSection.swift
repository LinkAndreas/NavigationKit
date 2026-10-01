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
public struct RootSection {
    let id: AnySectionID
    let title: LocalizedStringResource
    let icon: String?
    let root: AnyRoute
    let detail: AnyRoute?

    public init<ID: Hashable & Sendable, Root: Route>(
        _ id: ID,
        _ title: LocalizedStringResource,
        icon: String? = nil,
        root: () -> Root
    ) {
        self.init(id: AnySectionID(id), title: title, icon: icon, root: AnyRoute(root()), detail: nil)
    }

    public init<ID: Hashable & Sendable, Root: Route, Detail: Route>(
        _ id: ID,
        _ title: LocalizedStringResource,
        icon: String? = nil,
        root: () -> Root,
        detail: () -> Detail
    ) {
        self.init(id: AnySectionID(id), title: title, icon: icon, root: AnyRoute(root()), detail: AnyRoute(detail()))
    }

    init(id: AnySectionID, title: LocalizedStringResource, icon: String?, root: AnyRoute, detail: AnyRoute?) {
        self.id = id
        self.title = title
        self.icon = icon
        self.root = root
        self.detail = detail
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
