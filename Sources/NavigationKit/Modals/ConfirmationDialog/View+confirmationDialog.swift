import SwiftUI

extension View {
    /// Binds a `ConfirmationDialogSpec` to a standard SwiftUI `confirmationDialog` modifier.
    ///
    /// - Parameter spec: A binding to an optional `ConfirmationDialogSpec`. When non-nil, the dialog is presented.
    @ViewBuilder
    func confirmationDialog(spec: Binding<ConfirmationDialogSpec?>) -> some View {
        confirmationDialog(
            spec.wrappedValue?.title ?? "",
            isPresented: spec.isPresented,
            titleVisibility: .visible,
            actions: {
                if let current = spec.wrappedValue {
                    ForEach(current.buttons) { button in
                        Button(button.title, role: button.role) {
                            button.action()
                        }
                    }
                }
            },
            message: {
                if let message = spec.wrappedValue?.message {
                    Text(message)
                }
            }
        )
    }
}
