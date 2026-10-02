import Foundation
import Testing
@testable import NavigationKit

@MainActor
struct FlowTests {
    @Test func pushedFlowUnwindsExactlyItsScreens() async {
        let store = NavigationStore(root: HomeRoute.feed)
        let nav = store.navigator
        nav.push(HomeRoute.profile(id: "1"))

        async let result = nav.flow(ProofFlow())
        await settle()
        let flow = flowNavigator(store, ProofFlow.self)
        flow.next(.link)
        flowNavigator(store, ProofFlow.self).finish("done")

        #expect(await result == "done")
        #expect(store.currentSteps == [.push(HomeRoute.profile(id: "1"))])
    }

    @Test func backingOutOfFlowYieldsNil() async {
        let store = NavigationStore(root: HomeRoute.feed)
        async let result = store.navigator.flow(ProofFlow())
        await settle()
        store.navigator.pop()
        #expect(await result == nil)
    }

    @Test func presentedFlowFinishesByDismissing() async {
        let store = NavigationStore(root: HomeRoute.feed)
        async let result = store.navigator.flow(RegistrationFlow())
        await settle()
        flowNavigator(store, RegistrationFlow.self).next(.summary(proof: "doc"))
        flowNavigator(store, RegistrationFlow.self).finish(7)
        #expect(await result == 7)
        #expect(store.currentSteps.isEmpty)
    }
}

@MainActor
struct GuardTests {
    @Test func guardBlocksPop() async {
        let store = NavigationStore(root: HomeRoute.feed)
        store.navigator.push(HomeRoute.profile(id: "1"))
        let stack = store.sections[0].main
        stack.guards[stack.path[0].id] = { false }

        store.navigator.pop()
        await settle()
        #expect(store.currentSteps == [.push(HomeRoute.profile(id: "1"))])
        #expect(store.recentEvents.contains { if case .blockedByGuard = $0 { true } else { false } })

        stack.guards[stack.path[0].id] = { true }
        store.navigator.pop()
        await settle()
        #expect(store.currentSteps.isEmpty)
    }

    @Test func guardBlocksDismiss() async {
        let store = NavigationStore(root: HomeRoute.feed)
        store.navigator.present(ScheduleRoute.list)
        let modalStack = try! #require(store.sections[0].main.modal?.stack)
        modalStack.guards[modalStack.rootEntry.id] = { false }

        store.navigator.dismiss()
        await settle()
        #expect(store.sections[0].main.modal != nil)
    }
}

@MainActor
struct AuthTests {
    @Test func authGatePresentsLoginThenContinues() async {
        let session = Session()
        let store = NavigationStore(root: HomeRoute.feed)
        store.authCheck = { session.isLoggedIn }
        store.loginRoute = AnyRoute(HomeRoute.login)

        store.navigator.open(HomeRoute.settings)
        await settle()
        #expect(store.currentSteps == [.present(route: AnyRoute(HomeRoute.login), style: .cover)])

        session.isLoggedIn = true
        store.navigator.dismiss(returning: true)
        await settle()
        #expect(store.currentSteps == [.present(route: AnyRoute(HomeRoute.settings), style: .sheet(detents: [.medium]))])
    }
}

@MainActor
private final class Session {
    var isLoggedIn = false
}
