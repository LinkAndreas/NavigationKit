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
        /// The unique, type-erased identifier for this tab.
        public let id: AnyHashable
        
        /// The localized title string for this tab.
        public let title: String
        
        /// The SF Symbol image name for this tab's icon.
        public let systemImage: String
        
        /// The isolated stack navigator that drives the navigation hierarchy inside this tab.
        public let navigator: StackNavigator

        /// Creates a new tab.
        ///
        /// - Parameters:
        ///   - id: A unique `Hashable` identifier for the tab.
        ///   - title: The title string (will be resolved as a `LocalizedStringKey` in the UI).
        ///   - systemImage: The SF Symbol name for the tab icon.
        ///   - navigator: The `StackNavigator` managing this tab's internal hierarchy.
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

    /// The array of tabs hosted by this navigator.
    public internal(set) var tabs: [Tab]
    
    /// The `id` of the currently selected tab.
    public var selection: AnyHashable?
    
    /// The composed modal-presentation state (sheet, full screen cover, alert, etc.).
    public var modals = ModalBox()

    /// Creates a tabbed navigator hosting `tabs`.
    ///
    /// - Parameters:
    ///   - tabs: An array of ``Tab`` instances defining the interface.
    ///   - selection: The optional `id` of the tab to select initially. Defaults to the first tab.
    public init<ID: Hashable>(tabs: [Tab], selection: ID? = nil) {
        self.tabs = tabs
        if let selection {
            self.selection = AnyHashable(selection)
        } else {
            self.selection = tabs.first?.id
        }
    }

    /// Returns the internal stack navigators of all tabs so that modal dismissals can
    /// recursively cascade down the navigation hierarchy.
    public var presentableChildren: [any ModalPresenter] {
        tabs.map(\.navigator)
    }

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
