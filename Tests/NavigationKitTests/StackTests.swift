import Foundation
import Testing
@testable import NavigationKit

@MainActor
struct StackTests {
    @Test func pushPopAndPopToRoot() {
        let store = NavigationStore(root: HomeRoute.feed)
        let nav = store.navigator

        nav.push(HomeRoute.profile(id: "1"))
        nav.push(ScheduleRoute.session(id: "2"))
        #expect(store.currentSteps == [.push(HomeRoute.profile(id: "1")), .push(ScheduleRoute.session(id: "2"))])

        nav.pop()
        #expect(store.currentSteps == [.push(HomeRoute.profile(id: "1"))])

        nav.popToRoot()
        #expect(store.currentSteps.isEmpty)
    }

    @Test func popToReportsWhetherRouteWasFound() {
        let store = NavigationStore(root: HomeRoute.feed)
        let nav = store.navigator
        nav.push(HomeRoute.profile(id: "1"))
        nav.push(HomeRoute.profile(id: "2"))
        nav.push(HomeRoute.profile(id: "3"))

        #expect(nav.pop(to: HomeRoute.profile(id: "1")))
        #expect(store.currentSteps == [.push(HomeRoute.profile(id: "1"))])
        #expect(!nav.pop(to: HomeRoute.profile(id: "99")))
    }

    @Test func duplicatePushIsIgnored() {
        let store = NavigationStore(root: HomeRoute.feed)
        let nav = store.navigator
        nav.push(HomeRoute.profile(id: "1"))
        nav.push(HomeRoute.profile(id: "1"))
        #expect(store.currentSteps == [.push(HomeRoute.profile(id: "1"))])
        #expect(store.recentEvents.contains { if case .duplicatePushIgnored = $0 { true } else { false } })
    }

    @Test func popOnRootIsUnhandled() {
        let store = NavigationStore(root: HomeRoute.feed)
        #expect(store.navigator.perform(.pop) == false)
    }

    @Test func openUsesRouteTraits() {
        let store = NavigationStore(root: HomeRoute.feed)
        store.navigator.open(HomeRoute.profile(id: "1"))
        store.navigator.open(HomeRoute.login)
        #expect(store.currentSteps == [
            .push(HomeRoute.profile(id: "1")),
            .present(route: AnyRoute(HomeRoute.login), style: .cover),
        ])
    }
}
