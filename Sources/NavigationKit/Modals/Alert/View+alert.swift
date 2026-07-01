import SwiftUI

extension View {
    /// Binds an `AlertSpec` to a standard SwiftUI `alert` modifier.
    ///
    /// - Parameter spec: A binding to an optional `AlertSpec`. When non-nil, the alert is presented.
    func alert(spec: Binding<AlertSpec?>) -> some View {
        alert(
            spec.wrappedValue?.title ?? "",
            item: spec
        ) { spec in
            ForEach(spec.buttons) { button in
                Button(button.title, role: button.role) {
                    button.action()
                }
            }
        } message: { spec in
            if let message = spec.message {
                Text(message)
            }
        }
    }
    
    func alert(
        error: Binding<(any Error)?>,
        retry: (() -> Void)?
    ) -> some View {
        alert(error: error) { _ in
            if let retry {
                Button("Retry") { retry() }
                Button("Cancel", role: .cancel) {}
            }
            // else: system supplies the default OK button
        } message: { error in
            if let localized = error as? LocalizedError,
               let suggestion = localized.recoverySuggestion {
                Text(suggestion)
            } else {
                Text(error.localizedDescription)
            }
        }
    }
}
