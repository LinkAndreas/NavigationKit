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
    
    /// The navigator driving the currently presented sheet.
    ///
    /// When non-nil, SwiftUI presents a modal sheet hosting this navigator's stack.
    /// Modals are always represented by a `StackNavigator` internally.
    public var sheet: StackNavigator?
    
    /// The navigator driving the currently presented full-screen cover.
    ///
    /// When non-nil, SwiftUI presents a full-screen cover hosting this navigator's stack.
    public var fullScreenCover: StackNavigator?
    
    /// The specification for the currently presented alert.
    ///
    /// Set this property via `ModalPresenter.presentAlert` to trigger a native SwiftUI `.alert`.
    public var alert: AlertSpec?
    
    /// The specification for the currently presented confirmation dialog (action sheet).
    ///
    /// Set this property via `ModalPresenter.presentConfirmationDialog` to trigger a native SwiftUI `.confirmationDialog`.
    public var confirmationDialog: ConfirmationDialogSpec?
    
    /// The currently presented error, triggering a standardized error alert.
    ///
    /// When set, the system automatically presents an alert displaying the error's localized description.
    public var error: (any Error)?
    
    /// An optional retry closure associated with the currently presented error.
    ///
    /// If provided, the error alert will include a "Retry" button that executes this closure.
    /// This property is ignored by Observation to prevent unnecessary view updates.
    @ObservationIgnored public var errorRetry: (() -> Void)?
    
    /// A weak reference to the presenter that owns this modal box.
    ///
    /// This allows presented modals to communicate back to the navigator that presented them
    /// (e.g., to dismiss themselves via `dismiss()`).
    public weak var presentedBy: (any ModalPresenter)?

    /// Creates a new, empty modal state container.
    public init() {}
}
