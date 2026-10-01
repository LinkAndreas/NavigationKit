import SwiftUI

/// Attaches every presentation style to a stack, each bound to the stack's single modal slot.
struct ModalPresentationModifier: ViewModifier {
    let stack: StackNode

    private func binding(_ kind: PresentationStyle.Kind) -> Binding<ModalNode?> {
        Binding(
            get: { stack.modal.flatMap { $0.effectiveKind == kind ? $0 : nil } },
            set: { newValue in
                // The user dismissed it (swipe, tap outside, Escape).
                guard newValue == nil, let modal = stack.modal, modal.effectiveKind == kind else { return }
                stack.store?.closeModal(modal, result: nil)
            }
        )
    }

    func body(content: Content) -> some View {
        content
            .sheet(item: binding(.sheet)) { ModalContentView(modal: $0) }
            #if os(iOS)
            .fullScreenCover(item: binding(.cover)) { ModalContentView(modal: $0) }
            #endif
            .popover(item: binding(.popover)) { ModalContentView(modal: $0) }
            .inspector(isPresented: Binding(
                get: { binding(.inspector).wrappedValue != nil },
                set: { if !$0 { binding(.inspector).wrappedValue = nil } }
            )) {
                if let modal = binding(.inspector).wrappedValue {
                    ModalContentView(modal: modal)
                }
            }
    }
}

/// Presents the stack's pending `Dialog` as an alert or confirmation dialog.
struct DialogPresentationModifier: ViewModifier {
    let stack: StackNode

    private func isPresented(_ style: Dialog.Style) -> Binding<Bool> {
        Binding(
            get: { stack.dialog?.dialog.style == style },
            set: { presented in
                guard !presented, let request = stack.dialog, request.dialog.style == style else { return }
                // Button actions run before this setter settles; resolve as "dismissed" only if
                // no action claimed the request in the meantime.
                Task { @MainActor in
                    guard stack.dialog === request else { return }
                    request.finish(nil)
                    stack.dialog = nil
                }
            }
        )
    }

    func body(content: Content) -> some View {
        let request = stack.dialog
        let title = request.map { Text($0.dialog.title) } ?? Text(verbatim: "")
        content
            .alert(title, isPresented: isPresented(.alert), presenting: request) { request in
                actions(for: request)
            } message: { request in
                if let message = request.dialog.message { Text(message) }
            }
            .confirmationDialog(title, isPresented: isPresented(.confirmation), titleVisibility: .visible, presenting: request) { request in
                actions(for: request)
            } message: { request in
                if let message = request.dialog.message { Text(message) }
            }
    }

    @ViewBuilder
    private func actions(for request: DialogRequest) -> some View {
        ForEach(request.dialog.actions) { action in
            Button(role: action.role.buttonRole) {
                stack.store?.resolveDialog(on: stack, with: action)
            } label: {
                Text(action.title)
            }
        }
    }
}

extension Dialog.Action.Role {
    var buttonRole: ButtonRole? {
        switch self {
        case .default: nil
        case .cancel: .cancel
        case .destructive: .destructive
        }
    }
}
