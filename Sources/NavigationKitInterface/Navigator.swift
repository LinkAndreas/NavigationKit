import Foundation

/// The only navigation API a feature needs.
///
/// A navigator is *scoped* to the screen that received it. Each action travels up the tree until
/// a container can handle it: `push` lands on the nearest stack, `dismiss` closes the nearest
/// modal, `select` reaches the tabs or sidebar, `show` targets the detail column when there is
/// one. Screens therefore never need to know which layout they are rendered in.
///
/// The protocol has three requirements; everything else is convenience built on top, which
/// also makes test doubles trivial (see `RecordingNavigator` in `NavigationKitTesting`).
/// ``remember(for:_:)`` has a default implementation that doesn't keep anything.
public protocol Navigator: Sendable {
    /// Performs a fire-and-forget action. Returns `false` if nothing in the tree could handle it.
    @MainActor @discardableResult
    func perform(_ action: NavigationAction) -> Bool

    /// Performs an action that produces a value — `.present` or `.flow` — and suspends until the
    /// presented screen is dismissed or the flow finishes. Returns `nil` if it was cancelled (e.g. swiped away).
    @MainActor
    func result(of action: NavigationAction) async -> (any Sendable)?

    /// Shows a dialog and returns the ``Dialog/Action/id`` the user chose, or `nil` if dismissed.
    @MainActor
    func dialog(_ dialog: Dialog) async -> Dialog.Action.ID?

    /// Returns the value remembered for `lifetime`, creating it with `make` the first time.
    ///
    /// ```swift
    /// let api     = navigator.remember(for: .window) { CheckoutAPI() }
    /// let session = navigator.remember(for: .flow)   { CheckoutSession(api: api) }
    /// ```
    ///
    /// - The value is created only when first asked for, never up front.
    /// - Within one lifetime, every call for the same type returns the same value.
    /// - When the lifetime ends, the value is released; the next run starts fresh.
    ///
    /// Values are told apart by type: to keep two values of the same type, wrap them in distinct
    /// types. The type is the one `make` returns as the compiler infers it — when it can't infer
    /// it from the closure (e.g. one with several statements), annotate it:
    /// `let api: CheckoutAPI = navigator.remember(for: .window) { … }`.
    ///
    /// A screen that leaves its stack keeps its values while it animates out; they're released
    /// once its view is gone. See ``Lifetime`` for when each lifetime ends.
    @MainActor
    func remember<Value>(for lifetime: Lifetime, _ make: () -> Value) -> Value
}

public extension Navigator {
    /// Keeps nothing: calls `make` every time. Navigators backed by a `NavigationStore` remember.
    @MainActor
    func remember<Value>(for lifetime: Lifetime, _ make: () -> Value) -> Value { make() }
}

@MainActor
public extension Navigator {
    // MARK: Stack

    func push<R: Route>(_ route: R) { perform(.push(AnyRoute(route))) }

    /// Pushes or presents, depending on the route's ``Route/presentation`` trait.
    func open<R: Route>(_ route: R) { perform(.open(AnyRoute(route))) }

    func pop() { perform(.pop) }

    func popToRoot() { perform(.popToRoot) }

    /// Pops back to the most recent occurrence of `route`. Returns `false` if it isn't on the stack.
    @discardableResult
    func pop<R: Route>(to route: R) -> Bool { perform(.popTo(AnyRoute(route))) }

    // MARK: Modals

    /// Presents `route` modally. Without a style, the route's ``Route/presentation`` trait is
    /// used, falling back to a sheet.
    func present<R: Route>(_ route: R, as style: PresentationStyle? = nil) {
        perform(.present(AnyRoute(route), style))
    }

    /// Presents `route` and waits for it to be dismissed via ``dismiss(returning:)``.
    /// Returns `nil` if the user dismissed it another way.
    func present<R: Route, T: Sendable>(
        _ route: R,
        as style: PresentationStyle? = nil,
        returning: T.Type
    ) async -> T? {
        await result(of: .present(AnyRoute(route), style)) as? T
    }

    /// Dismisses the nearest modal.
    func dismiss() { perform(.dismiss(result: nil)) }

    /// Dismisses the nearest modal, handing `value` back to whoever awaited the presentation.
    func dismiss<T: Sendable>(returning value: T) { perform(.dismiss(result: value)) }

    // MARK: Sections & split views

    /// Selects a tab or sidebar item.
    func select<ID: Hashable & Sendable>(_ section: ID) { perform(.select(AnySectionID(section))) }

    /// Shows `route` in the detail column of a split view, or pushes it when there is none
    /// (for example, in compact width).
    func show<R: Route>(_ route: R) { perform(.show(AnyRoute(route))) }

    // MARK: Paths & deep links

    /// Replaces the current location with `steps`, starting from the selected section's root.
    func navigate(_ steps: [Step]) { perform(.navigate(steps)) }

    /// Opens a deep link through the app's deep-link handler.
    @discardableResult
    func open(_ url: URL) -> Bool { perform(.openURL(url)) }

    // MARK: Dialogs

    /// Shows a dialog built from its actions and returns the chosen action's ID.
    ///
    /// ```swift
    /// let choice = await navigator.dialog("Delete draft?", style: .confirmation) {
    ///     Dialog.Action("Delete", role: .destructive)
    ///     Dialog.Action("Cancel", role: .cancel)
    /// }
    /// ```
    func dialog(
        _ title: LocalizedStringResource,
        message: LocalizedStringResource? = nil,
        style: Dialog.Style = .alert,
        @DialogActionsBuilder actions: () -> [Dialog.Action]
    ) async -> Dialog.Action.ID? {
        await dialog(Dialog(title, message: message, style: style, actions: actions()))
    }

    /// Asks a yes/no question. Returns `true` only if the user confirmed.
    func confirm(
        _ title: LocalizedStringResource,
        message: LocalizedStringResource? = nil,
        confirm confirmTitle: LocalizedStringResource = "OK",
        destructive: Bool = false
    ) async -> Bool {
        let confirmID = "confirm"
        let choice = await dialog(Dialog(title, message: message, actions: [
            .cancel(),
            Dialog.Action(confirmTitle, role: destructive ? .destructive : .default, id: confirmID),
        ]))
        return choice == confirmID
    }

    /// Shows an informational alert and waits until it is acknowledged.
    func alert(_ title: LocalizedStringResource, message: LocalizedStringResource? = nil) async {
        _ = await dialog(Dialog(title, message: message, actions: [.default("OK")]))
    }

    /// Presents `error` with Retry and Cancel. Returns `true` if the user chose Retry.
    func retry(_ error: any Error, title: LocalizedStringResource = "Something went wrong") async -> Bool {
        let retryID = "retry"
        // Interpolated, so the already-localized description is shown as-is.
        let choice = await dialog(Dialog(title, message: "\(error.localizedDescription)", actions: [
            .cancel(),
            .default("Retry", id: retryID),
        ]))
        return choice == retryID
    }
}

// MARK: - Callbacks

/// Callback variants of the awaited calls, for call sites that would rather not start a `Task`:
/// a button action can present or ask and handle the outcome in a closure.
///
/// ```swift
/// navigator.present(PaymentRoute.add, returning: Card.self) { card in
///     if let card { model.use(card) }
/// }
///
/// navigator.dialog("Share", style: .confirmation) {
///     Dialog.Action("Copy Link") { model.copyLink() }
///     Dialog.Action("Cancel", role: .cancel)
/// }
/// ```
///
/// The presentation starts on the next main-actor turn; the closure runs once with the outcome.
public extension Navigator {
    /// Presents `route` and calls `onDismiss` with the value passed to ``dismiss(returning:)``,
    /// or `nil` if the user dismissed it another way.
    func present<R: Route, T: Sendable>(
        _ route: R,
        as style: PresentationStyle? = nil,
        returning: T.Type,
        onDismiss: @escaping @MainActor (T?) -> Void
    ) {
        Task { @MainActor in onDismiss(await present(route, as: style, returning: T.self)) }
    }

    /// Shows a dialog; the chosen action's handler runs, and `onDismiss` runs if the dialog is
    /// dismissed without choosing one.
    func dialog(
        _ title: LocalizedStringResource,
        message: LocalizedStringResource? = nil,
        style: Dialog.Style = .alert,
        @DialogActionsBuilder actions: () -> [Dialog.Action],
        onDismiss: (@MainActor () -> Void)? = nil
    ) {
        let dialog = Dialog(title, message: message, style: style, actions: actions())
        Task { @MainActor in
            if await self.dialog(dialog) == nil { onDismiss?() }
        }
    }

    /// Asks a yes/no question and calls `onConfirm` only if the user confirmed.
    func confirm(
        _ title: LocalizedStringResource,
        message: LocalizedStringResource? = nil,
        confirm confirmTitle: LocalizedStringResource = "OK",
        destructive: Bool = false,
        onConfirm: @escaping @MainActor () -> Void
    ) {
        Task { @MainActor in
            if await confirm(title, message: message, confirm: confirmTitle, destructive: destructive) {
                onConfirm()
            }
        }
    }

    /// Shows an informational alert and calls `onDismiss` once it is acknowledged.
    func alert(
        _ title: LocalizedStringResource,
        message: LocalizedStringResource? = nil,
        onDismiss: @escaping @MainActor () -> Void
    ) {
        Task { @MainActor in
            await alert(title, message: message)
            onDismiss()
        }
    }

    /// Presents `error` with Retry and Cancel, and calls `onRetry` if the user chose Retry.
    func retry(
        _ error: any Error,
        title: LocalizedStringResource = "Something went wrong",
        onRetry: @escaping @MainActor () -> Void
    ) {
        Task { @MainActor in
            if await retry(error, title: title) { onRetry() }
        }
    }
}

/// A navigator that knows the route type of the screen it was handed to, so call sites can use
/// leading-dot syntax for their own feature's routes: `navigator.push(.detail(id: id))`.
///
/// Routes of other features still work: `navigator.push(ScheduleRoute.list)`.
public struct RouteNavigator<R: Route>: Navigator {
    public let base: any Navigator

    public init(_ base: any Navigator) {
        if let typed = base as? RouteNavigator<R> {
            self = typed
        } else {
            self.base = base
        }
    }

    @MainActor @discardableResult
    public func perform(_ action: NavigationAction) -> Bool { base.perform(action) }

    @MainActor
    public func result(of action: NavigationAction) async -> (any Sendable)? { await base.result(of: action) }

    @MainActor
    public func dialog(_ dialog: Dialog) async -> Dialog.Action.ID? { await base.dialog(dialog) }

    @MainActor
    public func remember<Value>(for lifetime: Lifetime, _ make: () -> Value) -> Value {
        base.remember(for: lifetime, make)
    }

    /// Re-types this navigator for another feature's routes.
    public func typed<Other: Route>(_: Other.Type = Other.self) -> RouteNavigator<Other> { RouteNavigator<Other>(base) }

    // Typed overloads that enable leading-dot syntax for `R`.

    @MainActor public func push(_ route: R) { perform(.push(AnyRoute(route))) }
    @MainActor public func open(_ route: R) { perform(.open(AnyRoute(route))) }
    @MainActor @discardableResult public func pop(to route: R) -> Bool { perform(.popTo(AnyRoute(route))) }
    @MainActor public func present(_ route: R, as style: PresentationStyle? = nil) { perform(.present(AnyRoute(route), style)) }
    @MainActor public func present<T: Sendable>(_ route: R, as style: PresentationStyle? = nil, returning: T.Type) async -> T? {
        await result(of: .present(AnyRoute(route), style)) as? T
    }
    @MainActor public func show(_ route: R) { perform(.show(AnyRoute(route))) }
}

/// The navigator a view sees when it isn't inside a `NavigationRoot` (e.g. a bare preview).
/// Every action is a logged no-op.
public final class UnavailableNavigator: Navigator {
    public init() {}

    @MainActor @discardableResult
    public func perform(_ action: NavigationAction) -> Bool {
        #if DEBUG
        print("[NavigationKit] \(action) ignored: view is not inside a NavigationRoot.")
        #endif
        return false
    }

    @MainActor
    public func result(of action: NavigationAction) async -> (any Sendable)? {
        perform(action)
        return nil
    }

    @MainActor
    public func dialog(_ dialog: Dialog) async -> Dialog.Action.ID? { nil }
}

/// A source of deep links: maps a URL to a layout-independent list of ``Step``s.
public protocol DeepLinks {
    @MainActor static func steps(for url: URL) -> [Step]?
}
