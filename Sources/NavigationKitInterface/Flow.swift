import Foundation

/// A multi-step process that owns its steps: checkout, onboarding, a verification.
///
/// A flow declares its input (its properties), its steps and its result. Callers only start it;
/// the steps are private to the flow — only its ``FlowNavigator`` can show them:
///
/// ```swift
/// public struct Checkout: Flow {
///     public typealias Result = Order
///     public let cart: Cart                       // input, available in every step
///
///     public enum Step: Hashable, Codable, Sendable {
///         case review, address, payment(Address), done(Order)
///     }
///     public var start: Step { .review }
/// }
///
/// let order = await navigator.flow(Checkout(cart: cart))
/// ```
///
/// Its screens come from a `FlowModule`, which receives the step, the flow and a typed
/// ``FlowNavigator`` that continues (`next`), finishes (`finish`) or cancels the flow.
///
/// A flow is a ``Route``: its ``Route/presentation`` decides whether the whole flow is pushed or
/// presented, ``Route/hidesTabBar`` applies to all its steps, and ``Route/requiresAuth`` gates its
/// start.
public protocol Flow: Route {
    /// The flow's steps. Not a route: nothing outside the flow can show them.
    associatedtype Step: Hashable, Codable, Sendable
    /// What the flow produces. `Void` for flows that only need to complete.
    associatedtype Result: Sendable = Void

    /// The first step.
    var start: Step { get }
}

// MARK: - Starting a flow

@MainActor
public extension Navigator {
    /// Starts `flow` and waits for its result. Without a style, the flow's
    /// ``Route/presentation`` decides; `nil` pushes it onto the current stack.
    /// Returns `nil` if the flow was cancelled or the user backed out.
    @discardableResult
    func flow<F: Flow>(_ flow: F, as style: PresentationStyle? = nil) async -> F.Result? {
        await result(of: .flow(AnyRoute(flow), style)) as? F.Result
    }

    /// Starts `flow` from synchronous code, like a button action, and calls `onFinish` with its
    /// result. Nothing is called if the flow is cancelled or the user backs out.
    func flow<F: Flow>(
        _ flow: F,
        as style: PresentationStyle? = nil,
        onFinish: (@MainActor (F.Result) -> Void)? = nil
    ) {
        Task { @MainActor in
            if let result = await self.flow(flow, as: style) { onFinish?(result) }
        }
    }
}

// MARK: - Inside a flow

/// The navigator a flow's steps receive. It continues, finishes or cancels *this* flow — with
/// its own step and result types — and is a full ``Navigator`` for everything else (presenting,
/// dialogs, `remember`, starting other flows).
///
/// ```swift
/// case .review:
///     ReviewScreen(onNext: { navigator.next(.address) }, onCancel: { navigator.cancel() })
/// case let .done(order):
///     DoneScreen(onClose: { navigator.finish(order) })
/// ```
public struct FlowNavigator<F: Flow>: Navigator {
    public let base: any Navigator
    /// The running flow, with its input.
    public let flow: F
    /// Identifies this run of the flow; every step of the run carries it.
    package let run: UUID

    /// A navigator for `flow`, e.g. to test a flow's screens with a `RecordingNavigator`.
    public init(_ base: any Navigator, flow: F) {
        self.init(base, flow: flow, run: UUID())
    }

    package init(_ base: any Navigator, flow: F, run: UUID) {
        self.base = (base as? FlowNavigator<F>)?.base ?? base
        self.flow = flow
        self.run = run
    }

    /// Shows the next step of this flow.
    @MainActor public func next(_ step: F.Step) {
        perform(.push(AnyRoute(FlowStepRoute(flow: flow, step: step, run: run))))
    }

    /// Ends the flow with `result`, unwinding exactly its screens. Whoever started it gets `result`.
    @MainActor public func finish(_ result: F.Result) {
        perform(.finishFlow(result: result))
    }

    /// Ends the flow, unwinding its screens; whoever started it sees it as abandoned (`nil`).
    @MainActor public func cancel() {
        perform(.finishFlow(result: nil))
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
}

public extension FlowNavigator where F.Result == Void {
    /// Ends a flow that produces no value, unwinding its screens.
    @MainActor func finish() { finish(()) }
}

// MARK: - Steps on the stack

/// One step of a running flow, as it sits on a stack: the flow (with its input), the step, and
/// the run it belongs to. `Codable`, so a running flow can be restored. Created by
/// ``FlowNavigator``; you see it in navigation events and recorded actions.
public struct FlowStepRoute<F: Flow>: Route, CustomStringConvertible {
    public let flow: F
    public let step: F.Step
    package let run: UUID

    package init(flow: F, step: F.Step, run: UUID) {
        self.flow = flow
        self.step = step
        self.run = run
    }

    public static var routeKey: String { "FlowStep<\(F.routeKey)>" }
    public var hidesTabBar: Bool { flow.hidesTabBar }
    public var description: String { "\(F.self).\(step)" }
}

/// What the store needs to know about a step, whatever its flow.
package protocol AnyFlowStepRoute {
    var run: UUID { get }
    var flowRouteKey: String { get }
    var flowRoute: AnyRoute { get }
    /// The step, comparable across runs.
    var stepRoute: AnyHashable { get }
    var isFirstStep: Bool { get }
}

extension FlowStepRoute: AnyFlowStepRoute {
    package var flowRouteKey: String { F.routeKey }
    package var flowRoute: AnyRoute { AnyRoute(flow) }
    package var stepRoute: AnyHashable { AnyHashable(step) }
    package var isFirstStep: Bool { step == flow.start }
}

package extension Flow {
    /// The route of this flow's first step, for a new run.
    func firstStepRoute(run: UUID) -> AnyRoute {
        AnyRoute(FlowStepRoute(flow: self, step: start, run: run))
    }

    /// The route key of this flow's steps, for registration checks.
    static var stepRouteKey: String { FlowStepRoute<Self>.routeKey }
}
