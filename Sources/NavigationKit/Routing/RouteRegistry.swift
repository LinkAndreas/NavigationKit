import SwiftUI

/// Maps routes to views. Features contribute their screens as ``NavigationModule``s, and the app
/// lists them at the root: `NavigationRoot { … }.routes(ScheduleModule(), SpeakersModule())`.
///
/// Routes stay plain values, so a route enum can live in a lightweight *contracts* package that
/// other features import to navigate to it, while the screens live in the implementing feature.
/// Registering a type again replaces its screens, which lets the app override a feature's screen.
@MainActor
public final class RouteRegistry {
    private var builders: [String: (AnyRoute, any Navigator) -> AnyView] = [:]

    public init() {}

    public convenience init(_ modules: [any NavigationModule]) {
        self.init()
        modules.forEach { add($0) }
    }

    /// Adds a module's routes.
    public func add(_ module: any NavigationModule) {
        module.routeTypes.forEach { $0.registerForDecoding() }
        module.register(in: self)
    }

    /// Registers the view for a route type; the type is inferred from the closure.
    ///
    /// ```swift
    /// registry.register { (route: ScheduleRoute, navigator) in
    ///     ScheduleScreen(route: route, onSelect: { navigator.push(.session(id: $0)) })
    /// }
    /// ```
    public func register<R: Route, V: View>(
        _ type: R.Type = R.self,
        @ViewBuilder _ build: @escaping (R, RouteNavigator<R>) -> V
    ) {
        RouteTypes.register(R.self)
        builders[R.routeKey] = { route, navigator in
            guard let typed = route.as(R.self) else { return AnyView(EmptyView()) }
            return AnyView(build(typed, RouteNavigator<R>(navigator)))
        }
    }

    /// The route types among `types` that would show the "Unregistered route" placeholder. A
    /// ``Flow`` counts as covered when a ``FlowModule`` for it is registered. Returned as their ``Route/routeKey``s, for readable test
    /// failures.
    ///
    /// ```swift
    /// @Test func everyRouteHasAScreen() {
    ///     let registry = RouteRegistry(AppComposition.modules)
    ///     #expect(registry.missingViews(for: [ScheduleRoute.self, SpeakersRoute.self]).isEmpty)
    /// }
    /// ```
    public func missingViews(for types: [any Route.Type]) -> [String] {
        types.filter { !hasView(for: $0) }.map { $0.routeKey }
    }

    private func hasView(for type: any Route.Type) -> Bool {
        if let flow = type as? any Flow.Type { return builders[flow.stepRouteKey] != nil }
        return builders[type.routeKey] != nil
    }

    func view(for route: AnyRoute, navigator: any Navigator) -> AnyView? {
        builders[type(of: route.base).routeKey]?(route, navigator)
    }

    /// The registered screen, or a visible placeholder.
    static func resolve(_ route: AnyRoute, navigator: any Navigator, registry: RouteRegistry?) -> AnyView {
        let route = route.startingFlow
        if let view = registry?.view(for: route, navigator: navigator) { return view }
        return AnyView(UnregisteredRouteView(route: route))
    }
}

/// A feature's contribution to the registry. The app lists modules once at the root:
/// `NavigationRoot { … }.routes(ScheduleModule(), SpeakersModule())`.
public protocol NavigationModule {
    /// Route types to make decodable before any state is restored. Optional.
    var routeTypes: [any Route.Type] { get }

    @MainActor func register(in registry: RouteRegistry)
}

public extension NavigationModule {
    var routeTypes: [any Route.Type] { [] }
    @MainActor func register(in registry: RouteRegistry) {}
}

/// A module that provides the screens for exactly one route type, as an exhaustive `switch`: a
/// new case without a screen is a compile error, and the module can't register the wrong type.
/// ``NavigationModule/register(in:)`` and ``NavigationModule/routeTypes`` are provided.
///
/// ```swift
/// struct ScheduleModule: RouteModule {
///     let store: ScheduleStore
///
///     func body(for route: ScheduleRoute, navigator: RouteNavigator<ScheduleRoute>) -> some View {
///         switch route {
///         case .list: ScheduleList(store: store, onSelect: { navigator.show(.session(id: $0)) })
///         case let .session(id): SessionDetail(store: store, id: id)
///         }
///     }
/// }
/// ```
public protocol RouteModule: NavigationModule {
    associatedtype RouteType: Route
    associatedtype Screen: View
    @MainActor @ViewBuilder func body(for route: RouteType, navigator: RouteNavigator<RouteType>) -> Screen
}

public extension RouteModule {
    var routeTypes: [any Route.Type] { [RouteType.self] }

    @MainActor func register(in registry: RouteRegistry) {
        registry.register(RouteType.self) { route, navigator in body(for: route, navigator: navigator) }
    }
}

/// The screens of one ``Flow``: one `switch` over its steps, so the whole flow is wired in one
/// place. Each step gets the running flow (with its input) and a ``FlowNavigator`` that continues,
/// finishes or cancels it — with the flow's own step and result types.
///
/// ```swift
/// struct CheckoutScreens: FlowModule {
///     func body(for step: Checkout.Step, in flow: Checkout, navigator: FlowNavigator<Checkout>) -> some View {
///         switch step {
///         case .review:
///             ReviewScreen(cart: flow.cart, onNext: { navigator.next(.address) })
///         case .address:
///             AddressScreen(onConfirm: { navigator.next(.payment($0)) })
///         case let .payment(address):
///             PaymentScreen(address: address, onPaid: { navigator.next(.done($0)) })
///         case let .done(order):
///             DoneScreen(onClose: { navigator.finish(order) })
///         }
///     }
/// }
/// ```
///
/// List it like any module: `.routes(CheckoutScreens())`.
public protocol FlowModule: NavigationModule {
    associatedtype FlowType: Flow
    associatedtype Screen: View
    @MainActor @ViewBuilder func body(
        for step: FlowType.Step,
        in flow: FlowType,
        navigator: FlowNavigator<FlowType>
    ) -> Screen
}

public extension FlowModule {
    var routeTypes: [any Route.Type] { [FlowStepRoute<FlowType>.self] }

    @MainActor func register(in registry: RouteRegistry) {
        registry.register(FlowStepRoute<FlowType>.self) { route, navigator in
            body(for: route.step, in: route.flow, navigator: FlowNavigator(navigator.base, flow: route.flow, run: route.run))
        }
    }
}

extension Route {
    static func registerForDecoding() { RouteTypes.register(Self.self) }
}

struct UnregisteredRouteView: View {
    let route: AnyRoute

    var body: some View {
        ContentUnavailableView(
            "Unregistered route",
            systemImage: "exclamationmark.triangle",
            description: Text("\(route.description)\nRegister it in a NavigationModule and add the module with .routes(…).")
        )
        .foregroundStyle(.red)
    }
}
