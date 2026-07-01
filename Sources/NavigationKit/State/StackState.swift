import Foundation

/// A data-driven representation of a linear navigation stack and its associated modal presentations.
///
/// `StackState` allows you to define the state of a stack navigator purely through data.
/// It consists of a root route, an ordered path of pushed routes, and an optional modal.
///
/// **Example Usage:**
/// ```swift
/// let state = StackState(HomeRoute())
///     .pushing(ProfileRoute())
///     .presentingSheet(.stack(StackState(SettingsRoute())))
/// ```
public struct StackState: Equatable {
    /// The bottom-most route of the stack.
    public var root: AnyRoute
    
    /// The sequence of routes pushed on top of the root.
    public var path: [AnyRoute] = []
    
    /// The modal presentation (if any) currently displayed over this stack.
    public var modal: Modal? = nil

    /// Defines the type of modal presentation.
    public indirect enum Modal: Equatable {
        /// A bottom sheet presentation containing its own navigation state.
        case sheet(NavigationState)
        /// A full screen cover presentation containing its own navigation state.
        case fullScreenCover(NavigationState)
    }

    /// Initializes a new stack state with the given root route.
    ///
    /// - Parameter root: The `Hashable` route that serves as the root of the stack.
    public init<R: Hashable>(_ root: R) {
        self.root = AnyRoute(root)
    }
}

public extension StackState {
    /// Appends a single route to the stack's path.
    ///
    /// - Parameter r: The route to push.
    /// - Returns: A new `StackState` with the route appended.
    func pushing<R: Hashable>(_ r: R) -> StackState {
        var c = self
        c.path.append(AnyRoute(r))
        return c
    }
    
    /// Appends multiple routes to the stack's path in order.
    ///
    /// - Parameter rs: An array of routes to push.
    /// - Returns: A new `StackState` with the routes appended.
    func pushing<R: Hashable>(all rs: [R]) -> StackState {
        var c = self
        for r in rs {
            c.path.append(AnyRoute(r))
        }
        return c
    }

    /// Attaches a bottom sheet modal to this stack state.
    ///
    /// - Parameter s: The `NavigationState` to display inside the sheet.
    /// - Returns: A new `StackState` with the sheet modal attached.
    func presentingSheet(_ s: NavigationState) -> StackState {
        var c = self
        c.modal = .sheet(s)
        return c
    }

    /// Wraps this stack state inside a generic `NavigationState.stack`.
    var asState: NavigationState { .stack(self) }
}
