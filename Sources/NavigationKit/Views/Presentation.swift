import SwiftUI

/// Attaches the sheet, cover and popover styles to a stack, each bound to its single modal slot.
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
        // Inspectors are attached by `InspectorPresentationModifier`, which handles split columns.
        content
            .sheet(item: binding(.sheet)) { ModalContentView(modal: $0) }
            #if os(iOS)
            .fullScreenCover(item: binding(.cover)) { ModalContentView(modal: $0) }
            #endif
            .popover(item: binding(.popover)) { ModalContentView(modal: $0) }
    }
}

/// Shows an `.inspector` modal presented by any of `stacks`.
///
/// Inside a split view, an inspector must not wrap a column's `NavigationStack`: it re-hosts what
/// it wraps, so pushes past the first screen stop rendering, and sheets attached inside it lose
/// their window. Split columns therefore get their inspector on the `NavigationSplitView` (a
/// trailing column); every other stack gets it directly.
struct InspectorPresentationModifier: ViewModifier {
    let stacks: [StackNode]

    private var modal: ModalNode? {
        stacks.lazy.compactMap { $0.modal }.first { $0.effectiveKind == .inspector }
    }

    func body(content: Content) -> some View {
        if stacks.isEmpty {
            content
        } else {
            content.inspector(isPresented: Binding(
                get: { modal != nil },
                set: { presented in
                    guard !presented, let modal, let store = modal.presenter?.store else { return }
                    store.closeModal(modal, result: nil)
                }
            )) {
                if let modal {
                    ModalContentView(modal: modal)
                }
            }
        }
    }
}

/// Presents the stack's pending `Dialog` as an alert or confirmation dialog from its top screen.
///
/// Attached per screen, inside the `NavigationStack`: attached around the stack, alerts from pushed
/// screens never appear in a two-column split view on iPad.
struct DialogPresentationModifier: ViewModifier {
    let stack: StackNode
    let entryID: Entry.ID

    private var request: DialogRequest? {
        stack.entries.last?.id == entryID ? stack.dialog : nil
    }

    private func isPresented(_ style: Dialog.Style) -> Binding<Bool> {
        Binding(
            get: { request?.dialog.style == style },
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
        let request = request
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
