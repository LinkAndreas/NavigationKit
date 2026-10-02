import Foundation

/// An alert or confirmation dialog, described as data.
///
/// Texts are `LocalizedStringResource`s, so they're translated when shown, using the bundle they
/// were created in. Show a runtime string as-is by interpolating it: `"\(error.localizedDescription)"`.
///
/// Dialogs are awaited rather than wired up with state:
///
/// ```swift
/// let choice = await navigator.dialog(Dialog("Delete draft?", style: .confirmation) {
///     Dialog.Action("Delete", role: .destructive)
///     Dialog.Action("Cancel", role: .cancel)
/// })
/// ```
///
/// Inside the builder, write each action with its initializer, like a `Button` in a SwiftUI
/// alert. The `.default`, `.cancel` and `.destructive` shortcuts are for array literals, where
/// commas separate them; on consecutive builder lines Swift would chain them into one call.
///
/// Most call sites use the shortcuts ``Navigator/confirm(_:message:confirm:destructive:)``,
/// ``Navigator/alert(_:message:)`` and ``Navigator/retry(_:)`` instead.
public struct Dialog: Identifiable, Sendable {
    public enum Style: Hashable, Sendable {
        case alert
        case confirmation
    }

    public struct Action: Identifiable, Hashable, Sendable {
        public enum Role: Hashable, Sendable {
            case `default`, cancel, destructive
        }

        public let id: String
        public let title: LocalizedStringResource
        public let role: Role
        let handler: (@MainActor @Sendable () -> Void)?

        /// - Parameters:
        ///   - id: What the awaiting call returns when this action is chosen. Defaults to the title's key,
        ///     or ``cancelID`` for the cancel role.
        ///   - handler: Optional side effect, for callers that prefer not to await.
        public init(
            _ title: LocalizedStringResource,
            role: Role = .default,
            id: String? = nil,
            handler: (@MainActor @Sendable () -> Void)? = nil
        ) {
            self.id = id ?? (role == .cancel ? Action.cancelID : title.key)
            self.title = title
            self.role = role
            self.handler = handler
        }

        public static func `default`(_ title: LocalizedStringResource, id: String? = nil, handler: (@MainActor @Sendable () -> Void)? = nil) -> Action {
            Action(title, role: .default, id: id, handler: handler)
        }

        public static func cancel(_ title: LocalizedStringResource = "Cancel", handler: (@MainActor @Sendable () -> Void)? = nil) -> Action {
            Action(title, role: .cancel, handler: handler)
        }

        public static func destructive(_ title: LocalizedStringResource, id: String? = nil, handler: (@MainActor @Sendable () -> Void)? = nil) -> Action {
            Action(title, role: .destructive, id: id, handler: handler)
        }

        public static let cancelID = "cancel"

        @MainActor public func perform() { handler?() }

        public static func == (lhs: Action, rhs: Action) -> Bool {
            lhs.id == rhs.id && lhs.title.key == rhs.title.key && lhs.role == rhs.role
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(title.key)
            hasher.combine(role)
        }
    }

    public let id = UUID()
    public var title: LocalizedStringResource
    public var message: LocalizedStringResource?
    public var style: Style
    public var actions: [Action]

    public init(_ title: LocalizedStringResource, message: LocalizedStringResource? = nil, style: Style = .alert, actions: [Action]) {
        self.title = title
        self.message = message
        self.style = style
        self.actions = actions.isEmpty ? [.default("OK")] : actions
    }

    public init(
        _ title: LocalizedStringResource,
        message: LocalizedStringResource? = nil,
        style: Style = .alert,
        @DialogActionsBuilder actions: () -> [Action]
    ) {
        self.init(title, message: message, style: style, actions: actions())
    }
}

@resultBuilder
public enum DialogActionsBuilder {
    public static func buildExpression(_ action: Dialog.Action) -> [Dialog.Action] { [action] }
    public static func buildBlock(_ parts: [Dialog.Action]...) -> [Dialog.Action] { parts.flatMap { $0 } }
    public static func buildOptional(_ part: [Dialog.Action]?) -> [Dialog.Action] { part ?? [] }
    public static func buildEither(first: [Dialog.Action]) -> [Dialog.Action] { first }
    public static func buildEither(second: [Dialog.Action]) -> [Dialog.Action] { second }
    public static func buildArray(_ parts: [[Dialog.Action]]) -> [Dialog.Action] { parts.flatMap { $0 } }
}
