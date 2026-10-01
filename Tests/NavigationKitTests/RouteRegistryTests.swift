import SwiftUI
import Testing
@testable import NavigationKit

private enum SelfRenderingRoute: ViewRoute {
    case only

    func body(_ nav: RouteNavigator<Self>) -> some View { Text("Self-rendering") }
}

private struct ScheduleScreens: TypedRouteModule {
    func body(for route: ScheduleRoute, nav: RouteNavigator<ScheduleRoute>) -> some View {
        switch route {
        case .list, .placeholder: Text("List")
        case let .session(id), let .speaker(id): Text(id)
        }
    }
}

@MainActor
struct RouteRegistryTests {
    @Test func typedModuleRegistersItsRouteTypeThroughAnyRouteModule() {
        let modules: [any RouteModule] = [ScheduleScreens()]   // as .routes(…) receives them
        let registry = RouteRegistry(modules)

        #expect(registry.view(for: AnyRoute(ScheduleRoute.list), navigator: UnavailableNavigator()) != nil)
        #expect(modules[0].routeTypes.map { $0.routeKey } == [ScheduleRoute.routeKey])
    }

    @Test func missingViewsReportsRoutesWithoutAScreen() {
        let registry = RouteRegistry([ScheduleScreens()])

        let missing = registry.missingViews(for: [ScheduleRoute.self, SelfRenderingRoute.self, HomeRoute.self])

        #expect(missing == [HomeRoute.routeKey])
    }

    @Test func plainRegistrationsCountAsCovered() {
        let registry = RouteRegistry()
        registry.register { (route: HomeRoute, _) in Text(String(describing: route)) }

        #expect(registry.missingViews(for: [HomeRoute.self]).isEmpty)
    }
}
