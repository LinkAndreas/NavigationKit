import Foundation

/// An alert or confirmation dialog, described as data.
///
/// Dialogs are awaited rather than wired up with state:
///
/// ```swift
/// let choice = await nav.dialog(Dialog("Delete draft?", style: .confirmation) {
///     .destructive("Delete")
///     .cancel()
/// })
/// ```
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
        public let title: String
        public let role: Role
        let handler: (@MainActor @Sendable () -> Void)?

        /// - Parameters:
        ///   - id: What the awaiting call returns when this action is chosen. Defaults to `title`.
        ///   - handler: Optional side effect, for callers that prefer not to await.
        public init(
            _ title: String,
            role: Role = .default,
            id: String? = nil,
            handler: (@MainActor @Sendable () -> Void)? = nil
        ) {
            self.id = id ?? title
            self.title = title
            self.role = role
            self.handler = handler
        }

        public static func `default`(_ title: String, id: String? = nil, handler: (@MainActor @Sendable () -> Void)? = nil) -> Action {
            Action(title, role: .default, id: id, handler: handler)
        }

        public static func cancel(_ title: String = "Cancel", handler: (@MainActor @Sendable () -> Void)? = nil) -> Action {
            Action(title, role: .cancel, id: Action.cancelID, handler: handler)
        }

        public static func destructive(_ title: String, id: String? = nil, handler: (@MainActor @Sendable () -> Void)? = nil) -> Action {
            Action(title, role: .destructive, id: id, handler: handler)
        }

        public static let cancelID = "cancel"

        @MainActor public func perform() { handler?() }

        public static func == (lhs: Action, rhs: Action) -> Bool {
            lhs.id == rhs.id && lhs.title == rhs.title && lhs.role == rhs.role
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(title)
            hasher.combine(role)
        }
    }

    public let id = UUID()
    public var title: String
    public var message: String?
    public var style: Style
    public var actions: [Action]

    public init(_ title: String, message: String? = nil, style: Style = .alert, actions: [Action]) {
        self.title = title
        self.message = message
        self.style = style
        self.actions = actions.isEmpty ? [.default("OK")] : actions
    }

    public init(
        _ title: String,
        message: String? = nil,
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
