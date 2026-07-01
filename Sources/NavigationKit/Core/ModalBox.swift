import Foundation
import Observation

/// Shared modal-presentation storage, composed into every navigator type
/// (`StackNavigator`, `TabsNavigator`, `SplitNavigator`) via `ModalPresenter`.
///
/// Protocols can't supply stored properties, so without this composed object every
/// conforming navigator type would have to redeclare the same seven properties. Holding
/// them here means each navigator only needs `public var modals = ModalBox()`.
@Observable
@MainActor
public final class ModalBox {
    public var sheet: StackNavigator?
    public var fullScreenCover: StackNavigator?
    public var alert: AlertSpec?
    public var confirmationDialog: ConfirmationDialogSpec?
    public var error: (any Error)?
    @ObservationIgnored public var errorRetry: (() -> Void)?
    public weak var presentedBy: (any ModalPresenter)?

    public init() {}
}
