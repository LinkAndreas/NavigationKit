import SwiftUI

extension View {
    /// Binds a `ConfirmationDialogSpec` to a standard SwiftUI `confirmationDialog` modifier.
    ///
    /// - Parameter spec: A binding to an optional `ConfirmationDialogSpec`. When non-nil, the dialog is presented.
    func confirmationDialog(spec: Binding<ConfirmationDialogSpec?>) -> some View {
        confirmationDialog(
            spec.wrappedValue?.title ?? "",
            item: spec,
            titleVisibility: .visible,
            actions: { spec in
                ForEach(spec.buttons) { button in
                    Button(
                        button.title,
                        role: button.role,
                        action: button.action
                    )
                }
            },
            message: { spec in
                if let message = spec.message {
                    Text(message)
                }
            }
        )
    }
}
