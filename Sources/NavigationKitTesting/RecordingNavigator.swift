import Foundation
@_exported import NavigationKitInterface

/// A ``Navigator`` that records what a screen or view model asked for — no views needed.
///
/// ```swift
/// let nav = RecordingNavigator()
/// let model = SpeakerListModel(nav: nav)
/// model.didSelect(id: "s1")
/// #expect(nav.actions == [.push(AnyRoute(SpeakersRoute.detail(id: "s1")))])
/// ```
///
/// Script async answers with ``results`` (for `present(_:returning:)` and `flow`) and
/// ``dialogResponse`` (for `confirm`, `retry`, `dialog`).
///
/// `remember(for:_:)` keeps values per lifetime until you ``end(_:)`` it:
///
/// ```swift
/// let first = nav.remember(for: .flow) { CheckoutSession() }
/// nav.end(.flow)
/// #expect(nav.remember(for: .flow) { CheckoutSession() } !== first)
/// ```
@MainActor
public final class RecordingNavigator: Navigator {
    public private(set) var actions: [NavigationAction] = []
    public private(set) var dialogs: [Dialog] = []

    /// Values returned when a route is presented or a flow is started, keyed by route.
    public var results: [AnyRoute: any Sendable] = [:]

    /// Chooses the dialog action. Defaults to cancelling.
    public var dialogResponse: @MainActor (Dialog) -> Dialog.Action.ID? = { _ in nil }

    /// Whether actions count as handled. Defaults to always.
    public var handles: @MainActor (NavigationAction) -> Bool = { _ in true }

    /// Values kept by `remember(for:_:)`, per lifetime and type.
    private var remembered: [Lifetime: [ObjectIdentifier: Any]] = [:]

    public init() {}

    /// Shorthand for the routes pushed so far.
    public var pushedRoutes: [AnyRoute] {
        actions.compactMap { if case let .push(route) = $0 { route } else { nil } }
    }

    /// Answers every dialog with the action whose title key is `title`.
    public func answerDialogs(with title: String) {
        dialogResponse = { dialog in dialog.actions.first { $0.title.key == title }?.id }
    }

    public func reset() {
        actions = []
        dialogs = []
        remembered = [:]
    }

    /// Ends `lifetime`, as if its screen were popped or its flow had finished: everything
    /// remembered for it is released, and the next `remember(for:_:)` creates a new value.
    public func end(_ lifetime: Lifetime) {
        remembered[lifetime] = nil
    }

    public func remember<Value>(for lifetime: Lifetime, _ make: () -> Value) -> Value {
        let key = ObjectIdentifier(Value.self)
        if let value = remembered[lifetime]?[key] as? Value { return value }
        let value = make()
        remembered[lifetime, default: [:]][key] = value
        return value
    }

    @discardableResult
    public func perform(_ action: NavigationAction) -> Bool {
        actions.append(action)
        return handles(action)
    }

    public func result(of action: NavigationAction) async -> (any Sendable)? {
        actions.append(action)
        guard let route = action.targetRoute else { return nil }
        return results[route]
    }

    public func dialog(_ dialog: Dialog) async -> Dialog.Action.ID? {
        dialogs.append(dialog)
        let choice = dialogResponse(dialog)
        if let choice, let action = dialog.actions.first(where: { $0.id == choice }) {
            action.perform()
        }
        return choice
    }
}
