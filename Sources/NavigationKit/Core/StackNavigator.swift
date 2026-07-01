import Foundation
import Observation

/// A navigator driving a single linear navigation stack (root + pushed path), mirroring
/// SwiftUI's `NavigationStack`.
///
/// This is also the type used for any presented sheet or full-screen cover — modals are
/// always stack-shaped, so `ModalPresenter`'s `present(sheet:)` / `present(fullScreenCover:)`
/// always build a `StackNavigator`.
///
/// **Example Usage:**
/// ```swift
/// let navigator = StackNavigator(root: HomeRoute.feed)
/// navigator.push(HomeRoute.profile(id: "123"))
/// navigator.presentSheet(SettingsRoute.root)
/// ```
@Observable
@MainActor
public final class StackNavigator: ModalPresenter, Identifiable {
    public internal(set) var root: AnyRoute
    public var path: [AnyRoute] = []
    public var modals = ModalBox()

    /// Creates a stack navigator rooted at `root`.
    public init<R: Hashable>(root: R) {
        self.root = AnyRoute(root)
    }

    // MARK: - Stack navigation

    /// Pushes a new route onto the navigation stack.
    ///
    /// - Parameter r: The `Hashable` route to push.
    public func push<R: Hashable>(_ r: R) {
        path.append(AnyRoute(r))
    }

    /// Pops the topmost route off the navigation stack.
    public func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    /// Clears the navigation stack, returning the user to the root route.
    public func popToRoot() {
        path.removeAll()
    }

    /// Pops the stack back to the specific provided route, if it exists in the path.
    ///
    /// - Parameter route: The route to pop back to.
    public func popTo<R: Hashable>(_ route: R) {
        let routeAny = AnyRoute(route)
        if let index = path.lastIndex(of: routeAny) {
            let drops = path.count - 1 - index
            if drops > 0 {
                path.removeLast(drops)
            }
        }
    }

    // MARK: - Modals

    /// Presents a new route in a bottom sheet.
    ///
    /// This creates a new child `StackNavigator` specifically for the sheet, allowing the
    /// modal to maintain its own internal navigation stack.
    ///
    /// - Parameter route: The root route of the sheet.
    public func presentSheet<R: Hashable>(_ route: R) {
        let child = StackNavigator(root: route)
        child.modals.presentedBy = self
        modals.sheet = child
    }

    /// Presents a new route in a full screen cover.
    ///
    /// - Parameter route: The root route of the full screen cover.
    public func presentFullScreenCover<R: Hashable>(_ route: R) {
        let child = StackNavigator(root: route)
        child.modals.presentedBy = self
        modals.fullScreenCover = child
    }

    /// Dismisses this navigator if it is currently being presented as a modal (sheet or full screen cover).
    public func dismiss() {
        guard let presentedBy = modals.presentedBy else { return }
        if presentedBy.modals.sheet === self {
            presentedBy.modals.sheet = nil
        } else if presentedBy.modals.fullScreenCover === self {
            presentedBy.modals.fullScreenCover = nil
        }
    }

    // MARK: - Snapshots (deep links / restoration)

    /// Rebuilds this navigator's state from a previously captured `StackState` snapshot.
    ///
    /// - Parameter state: The snapshot to apply.
    public func apply(_ state: StackState) {
        root = state.root
        path = state.path
        applyModalTransition(state.modal)
    }

    /// Builds a stack navigator from a snapshot (used when restoring a presented modal from a
    /// deep link). Stacks only — tabbed and split modals need real chrome, so restoring those
    /// from a snapshot alone isn't supported.
    static func make(from state: NavigationState) -> StackNavigator? {
        switch state {
        case let .stack(s):
            let navigator = StackNavigator(root: s.root)
            navigator.apply(s)
            return navigator
        case .tabs:
            assertionFailure("Modal tabbed context must be presented with a prebuilt navigator.")
            return nil
        case .split:
            assertionFailure("Modal split context must be presented with a prebuilt navigator.")
            return nil
        }
    }
}
