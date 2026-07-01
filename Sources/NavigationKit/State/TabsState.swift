import Foundation

/// A data-driven representation of a multi-root tabbed navigation container.
///
/// `TabsState` allows you to define the selected tab, the specific navigation stacks within each tab,
/// and any modal presentations currently displayed over the tab container.
///
/// **Example Usage:**
/// ```swift
/// let state = TabsState(
///     selection: "profileTab",
///     tabs: [
///         "profileTab": StackState(ProfileRoute())
///     ]
/// )
/// ```
public struct TabsState: Equatable {
    /// The identifier of the tab that should be active. If `nil`, the selection remains unchanged.
    public var selection: AnyHashable?
    
    /// A dictionary mapping tab identifiers to their corresponding stack states.
    /// This only needs to contain the tabs you want to update.
    public var tabs: [AnyHashable: StackState]
    
    /// The modal presentation (if any) currently displayed over the tabs.
    public var modal: StackState.Modal? = nil

    /// Creates a new tabbed navigation state.
    ///
    /// - Parameters:
    ///   - selection: The identifier of the tab to select. Defaults to `nil` (unchanged).
    ///   - tabs: A dictionary of tab identifiers to their new stack states. Defaults to empty.
    ///   - modal: An optional modal presentation. Defaults to `nil`.
    public init<ID: Hashable>(
        selection: ID? = nil,
        tabs: [AnyHashable: StackState] = [:],
        modal: StackState.Modal? = nil
    ) {
        if let selection {
            self.selection = AnyHashable(selection)
        } else {
            self.selection = nil
        }
        self.tabs = tabs
        self.modal = modal
    }
}

public extension TabsState {
    /// Wraps this tab state inside a generic `NavigationState.tabs`.
    var asState: NavigationState { .tabs(self) }
}
