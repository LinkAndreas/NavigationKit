import SwiftUI

/// A declarative specification for a standard confirmation dialog (action sheet).
///
/// Under the hood, this uses the same data structure as `AlertSpec`, but is presented
/// as a bottom-anchored action sheet by the UI layer.
public typealias ConfirmationDialogSpec = AlertSpec   // same shape; different presenter
