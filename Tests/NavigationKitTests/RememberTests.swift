import Testing
import NavigationKitTesting
@testable import NavigationKit

private final class Session {}
private final class Cache {}

@MainActor
struct RememberTests {
    @Test func screenValueIsKeptWhileTheScreenIsOnItsStack() async {
        let store = NavigationStore(root: HomeRoute.feed)
        let nav = store.navigator
        nav.push(HomeRoute.profile(id: "1"))
        weak var released: Session?

        do {
            let session = nav.remember(for: .screen) { Session() }
            #expect(nav.remember(for: .screen) { Session() } === session)
            released = session
        }
        nav.pop()

        #expect(released == nil)
        nav.push(HomeRoute.profile(id: "1"))
        #expect(nav.remember(for: .screen) { Session() } !== released)
    }

    @Test func flowValueIsSharedByItsStepsAndReleasedWhenItFinishes() async {
        let store = NavigationStore(root: HomeRoute.feed)
        let nav = store.navigator
        weak var released: Session?

        nav.flow(OnboardingFlow()) {}
        await settle()
        do {
            let session = nav.remember(for: .flow) { Session() }
            nav.push(FlowRoute.step2)
            #expect(nav.remember(for: .flow) { Session() } === session)
            released = session
        }
        nav.finishFlow()
        await settle()

        #expect(released == nil)
    }

    @Test func eachRunOfAFlowStartsFresh() async {
        let store = NavigationStore(root: HomeRoute.feed)
        let nav = store.navigator
        weak var firstRun: Session?

        nav.flow(OnboardingFlow()) {}
        await settle()
        do { firstRun = nav.remember(for: .flow) { Session() } }
        nav.pop()                                           // backing out ends the run
        await settle()
        #expect(firstRun == nil)

        nav.flow(OnboardingFlow()) {}
        await settle()
        let secondRun = nav.remember(for: .flow) { Session() }
        nav.cancelFlow()
        await settle()
        #expect(store.currentSteps.isEmpty)
        _ = secondRun
    }

    @Test func nestedFlowHasItsOwnValueAndCanReachTheOuterOne() async {
        let store = NavigationStore(root: HomeRoute.feed)
        let nav = store.navigator

        nav.flow(OnboardingFlow()) {}
        await settle()
        let outer = nav.remember(for: .flow) { Session() }

        nav.flow(ProofFlow()) { _ in }
        await settle()
        let inner = nav.remember(for: .flow) { Session() }

        #expect(inner !== outer)
        #expect(nav.remember(for: .flow(OnboardingFlow.self)) { Session() } === outer)
        #expect(nav.remember(for: .flow(ProofFlow.self)) { Session() } === inner)

        nav.finishFlow(returning: "proof")
        await settle()
        #expect(nav.remember(for: .flow) { Session() } === outer)    // back in the outer flow
    }

    @Test func presentedFlowValueIsReleasedWhenItsModalCloses() async {
        let store = NavigationStore(root: HomeRoute.feed)
        let nav = store.navigator
        weak var released: Session?

        nav.flow(RegistrationFlow()) { _ in }                // its start step is a sheet
        await settle()
        do {
            let session = nav.remember(for: .flow) { Session() }
            nav.push(RegistrationStep.summary(proof: "doc"))
            #expect(nav.remember(for: .flow) { Session() } === session)
            released = session
        }
        nav.dismiss()
        await settle()

        #expect(released == nil)
    }

    @Test func outsideAFlowTheFlowLifetimeIsTheScreen() {
        let store = NavigationStore(root: HomeRoute.feed)
        let nav = store.navigator

        #expect(nav.remember(for: .flow) { Session() } === nav.remember(for: .screen) { Session() })
    }

    @Test func windowValueIsSharedAcrossSections() {
        let store = makeStore()
        let nav = store.navigator
        let cache = nav.remember(for: .window) { Cache() }

        nav.select(AppTab.schedule)
        nav.push(ScheduleRoute.session(id: "1"))

        #expect(nav.remember(for: .window) { Cache() } === cache)
    }

    @Test func valuesAreToldApartByType() {
        let store = NavigationStore(root: HomeRoute.feed)
        let nav = store.navigator
        let session = nav.remember(for: .screen) { Session() }
        let cache = nav.remember(for: .screen) { Cache() }

        #expect(nav.remember(for: .screen) { Session() } === session)
        #expect(nav.remember(for: .screen) { Cache() } === cache)
    }

    @Test func aScreenAnimatingOutKeepsItsValuesUntilItsViewGoesAway() {
        let store = NavigationStore(root: HomeRoute.feed)
        store.navigator.push(HomeRoute.profile(id: "1"))
        let stack = store.sections[0].main
        var created = 0
        weak var released: Session?

        do {
            let kept = ScreenMemories()                       // owned by the screen's view
            let render = { ScopedNavigator(stack: stack, entryID: stack.path.last!.id, kept: kept) }
            let screen = render()
            let session = screen.remember(for: .screen) { created += 1; return Session() }
            released = session
            store.navigator.pop()

            // Re-rendered while animating out: still the same value, nothing new is created.
            let again: Session = screen.remember(for: .screen) { created += 1; return Session() }
            #expect(again === session)
            #expect(created == 1)
        }

        #expect(released == nil)                              // the view went away: released once
    }

    @Test func recordingNavigatorRemembersUntilTheLifetimeEnds() {
        let nav = RecordingNavigator()
        let first = nav.remember(for: .flow) { Session() }
        #expect(nav.remember(for: .flow) { Session() } === first)

        nav.end(.flow)
        #expect(nav.remember(for: .flow) { Session() } !== first)
    }
}
