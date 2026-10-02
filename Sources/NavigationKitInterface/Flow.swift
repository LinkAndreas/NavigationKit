import Foundation

/// A reusable, multi-step process with a result — a sign-up, a checkout, a verification — that
/// callers start as one unit instead of knowing its first screen.
///
/// A flow is a route: a plain value, with parameters if it needs them. Its ``start`` names the
/// first step, and its ``Result`` is what ``Navigator/finishFlow(returning:)`` hands back:
///
/// ```swift
/// public struct ProofFlow: Flow {
///     public typealias Result = Proof
///     public let requirement: ProofRequirement
///     public var start: ProofRoute { .upload(requirement) }
/// }
/// ```
///
/// Steps are ordinary routes with screens from a module. A step continues with `push`, ends
/// with `finishFlow(returning:)`, and can run another flow as a step of its own:
///
/// ```swift
/// case let .teamDetails:
///     TeamDetailsScreen { requirement in
///         nav.flow(ProofFlow(requirement: requirement)) { proof in
///             nav.push(.summary(proof))
///         }
///     }
/// ```
///
/// Start a flow like any route — the result is typed:
///
/// ```swift
/// let registration = await nav.flow(HackathonRegistration())
/// ```
///
/// On screen, a flow *is* its start step: it pushes (or presents) ``start``, and
/// `finishFlow` unwinds exactly the screens the flow added. Backing out returns `nil`.
public protocol Flow: Route {
    /// The route of the flow's steps.
    associatedtype Step: Route
    /// What the flow produces. `Void` for flows that only need to complete.
    associatedtype Result: Sendable = Void

    /// The first step.
    var start: Step { get }
}

public extension Flow {
    /// Defaults to the start step's trait: a flow whose first step is a sheet runs in a sheet.
    var presentation: PresentationStyle? { start.presentation }
    /// Defaults to the start step's trait.
    var requiresAuth: Bool { start.requiresAuth }
    /// Defaults to the start step's trait.
    var hidesTabBar: Bool { start.hidesTabBar }
}

@MainActor
public extension Navigator {
    /// Starts `flow` and waits for its result. Without a style, the flow's
    /// ``Route/presentation`` decides; `nil` pushes it onto the current stack.
    /// Returns `nil` if the user backed out.
    @discardableResult
    func flow<F: Flow>(_ flow: F, as style: PresentationStyle? = nil) async -> F.Result? {
        guard let value = await result(of: .flow(AnyRoute(flow), style)) else { return nil }
        // `finishFlow()` reports completion without a value; that finishes a `Void` flow.
        return value as? F.Result ?? (() as? F.Result)
    }

    /// Starts `flow` from synchronous code, like a button action, and calls `onFinish` with its
    /// result. Nothing is called if the user backs out — the screen that started it is simply on
    /// top again.
    func flow<F: Flow>(
        _ flow: F,
        as style: PresentationStyle? = nil,
        onFinish: (@MainActor (F.Result) -> Void)? = nil
    ) {
        Task { @MainActor in
            if let result = await self.flow(flow, as: style) { onFinish?(result) }
        }
    }

    /// Ends the innermost running flow without a result, unwinding its screens. Whoever started
    /// it sees the flow as abandoned.
    func cancelFlow() { perform(.finishFlow(result: nil)) }
}
