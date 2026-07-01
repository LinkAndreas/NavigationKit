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
    var presentableChildren: [any ModalPresenter] { [] }

    func present<R: Hashable>(sheet route: R) {
        let navigator = StackNavigator(root: route)
        navigator.modals.presentedBy = self
        modals.sheet = navigator
    }

    func present<R: Hashable>(fullScreenCover route: R) {
        let navigator = StackNavigator(root: route)
        navigator.modals.presentedBy = self
        modals.fullScreenCover = navigator
    }

    func present(alert a: AlertSpec) { modals.alert = a }

    func present(error: any Error, retry: (() -> Void)? = nil) {
        modals.errorRetry = retry
        modals.error = error
    }

    func present(confirmationDialog d: ConfirmationDialogSpec) { modals.confirmationDialog = d }

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
