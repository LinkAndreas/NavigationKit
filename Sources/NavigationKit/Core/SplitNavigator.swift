import Foundation
import Observation

/// A navigator driving a `NavigationSplitView` sidebar/content/detail hierarchy.
///
/// `sidebar` and `detail` always exist; `content` is only used for three-column layouts.
/// Each column is its own independent `StackNavigator`, so it keeps its own push history.
///
/// **Example Usage:**
/// ```swift
/// let splitNavigator = SplitNavigator(
///     sidebar: StackNavigator(root: SidebarRoute.menu),
///     detail: StackNavigator(root: DetailRoute.empty)
/// )
/// ```
@Observable
@MainActor
public final class SplitNavigator: ModalPresenter, Identifiable {
    public internal(set) var sidebar: StackNavigator
    public internal(set) var content: StackNavigator?
    public internal(set) var detail: StackNavigator
    public var columnVisibility: SplitVisibility = .automatic
    public var modals = ModalBox()

    /// Creates a split navigator hosting a sidebar, an optional content column, and a detail column.
    ///
    /// - Parameters:
    ///   - sidebar: The navigator driving the sidebar column.
    ///   - content: The navigator driving the optional middle column (three-column layouts).
    ///   - detail: The navigator driving the detail column.
    ///   - columnVisibility: The initial column visibility. Defaults to `.automatic`.
    public init(
        sidebar: StackNavigator,
        content: StackNavigator? = nil,
        detail: StackNavigator,
        columnVisibility: SplitVisibility = .automatic
    ) {
        self.sidebar = sidebar
        self.content = content
        self.detail = detail
        self.columnVisibility = columnVisibility
    }

    public var presentableChildren: [any ModalPresenter] {
        [sidebar, content, detail].compactMap { $0 }
    }

    // MARK: - Split navigation

    /// Replaces the root route displayed in the detail column.
    ///
    /// This is the typical way to react to a sidebar selection: it resets the detail
    /// navigator's path so the newly selected item is shown without leftover pushed routes.
    ///
    /// - Parameter route: The root route to display in the detail column.
    public func showDetail<R: Hashable>(_ route: R) {
        detail.root = AnyRoute(route)
        detail.path = []
    }

    /// Replaces the root route displayed in the optional middle (content) column.
    ///
    /// - Parameter route: The root route to display in the content column.
    public func showContent<R: Hashable>(_ route: R) {
        guard let content else {
            self.content = StackNavigator(root: route)
            return
        }
        content.root = AnyRoute(route)
        content.path = []
    }

    // MARK: - Snapshots (deep links / restoration)

    /// Rebuilds this navigator's state from a previously captured `SplitState` snapshot.
    ///
    /// - Parameter state: The snapshot to apply.
    public func apply(_ state: SplitState) {
        if let sidebarState = state.sidebar {
            sidebar.apply(sidebarState)
        }
        if let contentState = state.content {
            content?.apply(contentState)
        }
        if let detailState = state.detail {
            detail.apply(detailState)
        }
        if let columnVisibility = state.columnVisibility {
            self.columnVisibility = columnVisibility
        }
        applyModalTransition(state.modal)
    }
}
