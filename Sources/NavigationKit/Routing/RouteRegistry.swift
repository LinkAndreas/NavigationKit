import SwiftUI

/// A route that knows how to render itself. The simplest way to add screens: the feature that
/// owns the route also owns its view, and no registration is needed.
///
/// ```swift
/// enum SpeakersRoute: ViewRoute {
///     case overview, detail(id: String)
///
///     func body(_ nav: RouteNavigator<Self>) -> some View {
///         switch self {
///         case .overview: SpeakerList(onSelect: { nav.push(.detail(id: $0)) })
///         case let .detail(id): SpeakerDetail(id: id)
///         }
///     }
/// }
/// ```
public protocol ViewRoute: Route {
    associatedtype Body: View
    @MainActor @ViewBuilder func body(_ nav: RouteNavigator<Self>) -> Body
}

extension ViewRoute {
    @MainActor func erasedBody(_ navigator: any Navigator) -> AnyView {
        AnyView(body(RouteNavigator<Self>(navigator)))
    }
}

/// Maps routes to views when a route can't render itself — typically because the route enum
/// lives in a lightweight *contracts* package that other features import to navigate to it,
/// while the screens live in the implementing feature.
///
/// A registered builder takes precedence over ``ViewRoute/body(_:)``, which also lets the app
/// override a feature's screen.
@MainActor
public final class RouteRegistry {
    private var builders: [String: (AnyRoute, any Navigator) -> AnyView] = [:]

    public init() {}

    public convenience init(_ modules: [any RouteModule]) {
        self.init()
        modules.forEach { add($0) }
    }

    /// Adds a module's routes.
    public func add(_ module: any RouteModule) {
        module.routeTypes.forEach { $0.registerForDecoding() }
        module.register(in: self)
    }

    /// Registers the view for a route type; the type is inferred from the closure.
    ///
    /// ```swift
    /// registry.register { (route: ScheduleRoute, nav) in
    ///     ScheduleScreen(route: route, onSelect: { nav.push(.session(id: $0)) })
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

    /// The route types among `types` that would show the "Unregistered route" placeholder: neither
    /// registered here nor ``ViewRoute``s. Returned as their ``Route/routeKey``s, for readable test
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
        builders[type.routeKey] != nil || type is any ViewRoute.Type
    }

    func view(for route: AnyRoute, navigator: any Navigator) -> AnyView? {
        builders[type(of: route.base).routeKey]?(route, navigator)
    }

    /// Resolution order: registry builder, then ``ViewRoute``, then a visible placeholder.
    static func resolve(_ route: AnyRoute, navigator: any Navigator, registry: RouteRegistry?) -> AnyView {
        if let view = registry?.view(for: route, navigator: navigator) { return view }
        if let viewRoute = route.base as? any ViewRoute { return viewRoute.erasedBody(navigator) }
        return AnyView(UnregisteredRouteView(route: route))
    }
}

/// A feature's contribution to the registry. The app lists modules once at the root:
/// `NavigationRoot { … }.routes(ScheduleModule(), SpeakersModule())`.
public protocol RouteModule {
    /// Route types to make decodable before any state is restored. Optional.
    var routeTypes: [any Route.Type] { get }

    @MainActor func register(in registry: RouteRegistry)
}

public extension RouteModule {
    var routeTypes: [any Route.Type] { [] }
    @MainActor func register(in registry: RouteRegistry) {}
}

/// A module that provides the screens for exactly one route type, as an exhaustive `switch`: a
/// new case without a screen is a compile error, and the module can't register the wrong type.
/// ``RouteModule/register(in:)`` and ``RouteModule/routeTypes`` are provided.
///
/// ```swift
/// struct ScheduleModule: TypedRouteModule {
///     let store: ScheduleStore
///
///     func body(for route: ScheduleRoute, nav: RouteNavigator<ScheduleRoute>) -> some View {
///         switch route {
///         case .list: ScheduleList(store: store, onSelect: { nav.show(.session(id: $0)) })
///         case let .session(id): SessionDetail(store: store, id: id)
///         }
///     }
/// }
/// ```
public protocol TypedRouteModule: RouteModule {
    associatedtype RouteType: Route
    associatedtype Screen: View
    @MainActor @ViewBuilder func body(for route: RouteType, nav: RouteNavigator<RouteType>) -> Screen
}

public extension TypedRouteModule {
    var routeTypes: [any Route.Type] { [RouteType.self] }

    @MainActor func register(in registry: RouteRegistry) {
        registry.register(RouteType.self) { route, nav in body(for: route, nav: nav) }
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
            description: Text("\(route.description)\nConform it to ViewRoute or register it in a RouteModule.")
        )
        .foregroundStyle(.red)
    }
}
