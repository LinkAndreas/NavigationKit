import Foundation

/// A protocol defining the ability to present and dismiss modals.
///
/// `ModalPresenter` is adopted by every navigator type (`StackNavigator`, `TabsNavigator`,
/// `SplitNavigator`). Conformers hold their modal state in a single ``ModalBox``, so these
/// default implementations are shared without duplicating storage per type.
@MainActor
public protocol ModalPresenter: AnyObject {
    /// The composed modal-presentation state (sheet, full screen cover, alert, etc.).
    var modals: ModalBox { get }

    /// Other navigators reachable from this one, recursed into by `dismissAllModals()`.
    /// `StackNavigator` has none; `TabsNavigator` returns its tabs; `SplitNavigator` returns
    /// its sidebar/content/detail.
    var presentableChildren: [any ModalPresenter] { get }
}

public extension ModalPresenter {
    /// Returns the children of this navigator, allowing recursive operations like dismissing all modals.
    /// By default, navigators have no children (an empty array).
    var presentableChildren: [any ModalPresenter] { [] }

    /// Presents a given route as a modal sheet.
    ///
    /// - Parameter route: The `Hashable` route representing the destination to present.
    ///
    /// Internally, this wraps the route in a new `StackNavigator` and assigns it to `modals.sheet`.
    func present<R: Hashable>(sheet route: R) {
        let navigator = StackNavigator(root: route)
        navigator.modals.presentedBy = self
        modals.sheet = navigator
    }

    /// Presents a given route as a full-screen cover.
    ///
    /// - Parameter route: The `Hashable` route representing the destination to present.
    ///
    /// Internally, this wraps the route in a new `StackNavigator` and assigns it to `modals.fullScreenCover`.
    func present<R: Hashable>(fullScreenCover route: R) {
        let navigator = StackNavigator(root: route)
        navigator.modals.presentedBy = self
        modals.fullScreenCover = navigator
    }

    /// Presents a native SwiftUI alert.
    ///
    /// - Parameter a: An `AlertSpec` defining the alert's title, message, and buttons.
    func present(alert a: AlertSpec) { modals.alert = a }

    /// Presents a native SwiftUI error alert.
    ///
    /// - Parameters:
    ///   - error: The `Error` to display.
    ///   - retry: An optional closure to execute if the user taps "Retry".
    func present(error: any Error, retry: (() -> Void)? = nil) {
        modals.errorRetry = retry
        modals.error = error
    }

    /// Presents a native SwiftUI confirmation dialog (action sheet).
    ///
    /// - Parameter d: A `ConfirmationDialogSpec` defining the dialog's title, message, and buttons.
    func present(confirmationDialog d: ConfirmationDialogSpec) { modals.confirmationDialog = d }

    /// Dismisses any currently presented modal (sheet, full-screen cover, alert, or confirmation dialog).
    ///
    /// If this navigator was presented by another navigator, it recursively climbs the hierarchy and
    /// asks the root presenting navigator to dismiss all modals. It also cascades the dismissal command
    /// to any `presentableChildren`.
    func dismissAllModals() {
        if let presentedBy = modals.presentedBy {
            presentedBy.dismissAllModals()
            return
        }

        modals.alert = nil
        modals.confirmationDialog = nil
        modals.error = nil
        modals.errorRetry = nil
        modals.sheet = nil
        modals.fullScreenCover = nil

        for child in presentableChildren {
            child.dismissAllModals()
        }
    }
}

// MARK: - Deep link modal restoration

/// Shared by `StackNavigator`/`TabsNavigator`/`SplitNavigator`'s `apply(_:)` — every snapshot
/// type ends in "dismiss whatever's currently presented, then re-present what the new state
/// describes."
extension ModalPresenter {
    /// Dismisses any presented modal, then re-presents whatever `modal` describes — after a
    /// brief delay if a modal had to be dismissed first, to let SwiftUI's dismissal animation
    /// settle.
    func applyModalTransition(_ modal: StackState.Modal?) {
        let hadModal = (modals.sheet != nil) || (modals.fullScreenCover != nil)
        dismissAllModals()

        if hadModal {
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 100_000_000)
                applyModal(modal)
            }
        } else {
            applyModal(modal)
        }
    }

    private func applyModal(_ modal: StackState.Modal?) {
        switch modal {
        case let .sheet(state):
            if let navigator = StackNavigator.make(from: state) {
                navigator.modals.presentedBy = self
                modals.sheet = navigator
            }
        case let .fullScreenCover(state):
            if let navigator = StackNavigator.make(from: state) {
                navigator.modals.presentedBy = self
                modals.fullScreenCover = navigator
            }
        case nil:
            break
        }
    }
}
