import SwiftUI

/// Represents a complete snapshot of a navigation hierarchy.
///
/// `NavigationState` encapsulates the state of the app's navigation at a specific point in time.
/// It can represent either a simple stack (linear navigation) or a tabbed interface (multi-root navigation).
public enum NavigationState: Equatable {
    /// A linear navigation state containing a stack path and an optional presented modal.
    case stack(StackState)
    /// A multi-root navigation state containing multiple tabs, each with their own stack path.
    case tabs(TabsState)
    /// A split navigation state containing a sidebar, optional content, and detail column.
    case split(SplitState)
}

/// Applies a parsed `NavigationState` to an existing `RootNavigator`.
///
/// This function attempts to apply the incoming state snapshot to the navigator's underlying
/// state manager. If the shape (stack vs tabs vs split) of the incoming state does not match
/// the current navigator's shape, the operation is ignored.
///
/// - Parameters:
///   - state: The desired target `NavigationState` snapshot.
///   - navigator: The active `RootNavigator` instance to apply the state to.
@MainActor
public func applyDeepLink(_ state: NavigationState, to navigator: RootNavigator) {
    switch (navigator, state) {
    case let (.stack(navigator), .stack(navigationState)):
        navigator.apply(navigationState)
    case let (.tabs(navigator), .tabs(navigationState)):
        navigator.apply(navigationState)
    case let (.split(navigator), .split(navigationState)):
        navigator.apply(navigationState)
    default:
        break   // shape mismatch — ignore (or route to a safe fallback)
    }
}
