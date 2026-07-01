import Foundation
import Observation

/// A navigator driving a multi-root tabbed interface.
///
/// Each tab wraps its own independent `StackNavigator`, so every tab keeps its own push
/// history.
///
/// **Example Usage:**
/// ```swift
/// let appNavigator = TabsNavigator(tabs: [
///     TabsNavigator.Tab(id: "home", title: "Home", systemImage: "house", navigator: StackNavigator(root: HomeRoute())),
///     TabsNavigator.Tab(id: "settings", title: "Settings", systemImage: "gear", navigator: StackNavigator(root: SettingsRoute()))
/// ])
/// ```
@Observable
@MainActor
public final class TabsNavigator: ModalPresenter, Identifiable {
    public struct Tab: Identifiable {
        public let id: AnyHashable
        public let title: String
        public let systemImage: String
        public let navigator: StackNavigator

        public init<ID: Hashable>(
            id: ID,
            title: String,
            systemImage: String,
            navigator: StackNavigator
        ) {
            self.id = AnyHashable(id)
            self.title = title
            self.systemImage = systemImage
            self.navigator = navigator
        }
    }

    public internal(set) var tabs: [Tab]
    public var selection: AnyHashable?
    public var modals = ModalBox()

    /// Creates a tabbed navigator hosting `tabs`.
    public init<ID: Hashable>(tabs: [Tab], selection: ID? = nil) {
        self.tabs = tabs
        if let selection {
            self.selection = AnyHashable(selection)
        } else {
            self.selection = tabs.first?.id
        }
    }

    public var presentableChildren: [any ModalPresenter] { tabs.map(\.navigator) }

    // MARK: - Tab selection

    /// Selects a specific tab by its identifier.
    ///
    /// - Parameter id: The identifier of the tab to select.
    public func select<ID: Hashable>(_ id: ID) {
        selection = AnyHashable(id)
    }

    public func navigator<ID: Hashable>(for id: ID) -> StackNavigator? {
        tabs.first { $0.id == AnyHashable(id) }?.navigator
    }

    public var selectedNavigator: StackNavigator? {
        if let selection {
            return navigator(for: selection)
        }
        return nil
    }

    // MARK: - Snapshots (deep links / restoration)

    /// Rebuilds this navigator's state from a previously captured `TabsState` snapshot.
    ///
    /// - Parameter state: The snapshot to apply.
    public func apply(_ state: TabsState) {
        if let selection = state.selection {
            self.selection = selection
        }
        for (id, stack) in state.tabs {
            navigator(for: id)?.apply(stack)
        }
        applyModalTransition(state.modal)
    }
}
