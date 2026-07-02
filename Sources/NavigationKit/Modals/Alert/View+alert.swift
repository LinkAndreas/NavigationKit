import SwiftUI

extension View {
    /// Binds an `AlertSpec` to a standard SwiftUI `alert` modifier.
    ///
    /// - Parameter spec: A binding to an optional `AlertSpec`. When non-nil, the alert is presented.
    @ViewBuilder
    func alert(spec: Binding<AlertSpec?>) -> some View {
        if #available(iOS 27.0, macOS 27.0, *) {
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
        } else {
            alert(
                spec.wrappedValue?.title ?? "",
                isPresented: spec.isPresented,
                presenting: spec.wrappedValue
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
    }
    
    @ViewBuilder
    func alert(
        error: Binding<(any Error)?>,
        retry: (() -> Void)?
    ) -> some View {
        if #available(iOS 27.0, macOS 27.0, *) {
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
        } else {
            let title = (error.wrappedValue as? LocalizedError)?.errorDescription
                ?? error.wrappedValue?.localizedDescription
                ?? "Error"
            alert(
                title,
                isPresented: error.isPresented,
                presenting: error.wrappedValue
            ) { _ in
                if let retry {
                    Button("Retry", action: retry)
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
}
