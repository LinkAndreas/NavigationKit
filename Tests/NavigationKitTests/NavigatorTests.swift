import Foundation
import Testing
@testable import NavigationKit
import NavigationKitTesting

@MainActor
struct RecordingNavigatorTests {
    @Test func recordsActions() {
        let nav = RecordingNavigator()
        nav.push(HomeRoute.profile(id: "1"))
        nav.present(HomeRoute.settings, as: .sheet)
        nav.select(AppTab.schedule)
        nav.dismiss()

        #expect(nav.actions == [
            .push(AnyRoute(HomeRoute.profile(id: "1"))),
            .present(AnyRoute(HomeRoute.settings), .sheet),
            .select(AnySectionID(AppTab.schedule)),
            .dismiss(result: nil),
        ])
    }

    @Test func scriptsAsyncAnswers() async {
        let nav = RecordingNavigator()
        nav.results[AnyRoute(ScheduleRoute.list)] = "picked"
        nav.answerDialogs(with: "Retry")

        #expect(await nav.present(ScheduleRoute.list, returning: String.self) == "picked")
        #expect(await nav.retry(URLError(.timedOut)))
    }

    @Test func routeNavigatorEnablesLeadingDotSyntax() {
        let recorder = RecordingNavigator()
        let nav = RouteNavigator<ScheduleRoute>(recorder)
        nav.push(.session(id: "1"))
        nav.push(HomeRoute.feed)
        #expect(recorder.pushedRoutes == [AnyRoute(ScheduleRoute.session(id: "1")), AnyRoute(HomeRoute.feed)])
    }
}

struct AnyRouteTests {
    @Test func equalityRespectsType() {
        #expect(AnyRoute(ScheduleRoute.list) == AnyRoute(ScheduleRoute.list))
        #expect(AnyRoute(ScheduleRoute.list) != AnyRoute(HomeRoute.feed))
    }

    @Test func codableRoundTrip() throws {
        let route = AnyRoute(ScheduleRoute.session(id: "42"))
        let decoded = try JSONDecoder().decode(AnyRoute.self, from: JSONEncoder().encode(route))
        #expect(decoded == route)
    }
}
