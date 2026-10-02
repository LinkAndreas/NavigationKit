import Testing
@testable import NavigationKit

@MainActor
struct ComposedFlowTests {
    @Test func flowIsShownAsItsStartStepAndReturnsATypedResult() async {
        let store = NavigationStore(root: HomeRoute.feed)
        let nav = store.navigator

        async let proof = nav.flow(ProofFlow())
        await settle()
        #expect(store.currentSteps == [.push(ProofStep.upload(required: true))])

        nav.push(ProofStep.link)
        nav.finishFlow(returning: "repo-url")

        #expect(await proof == "repo-url")
        #expect(store.currentSteps.isEmpty)
    }

    @Test func voidFlowFinishesWithoutAValue() async {
        let store = NavigationStore(root: HomeRoute.feed)
        var finished = false

        store.navigator.flow(OnboardingFlow()) { finished = true }
        await settle()
        store.navigator.push(FlowRoute.step2)
        store.navigator.finishFlow()
        await settle()

        #expect(finished)
        #expect(store.currentSteps.isEmpty)
    }

    @Test func backingOutDoesNotCallOnFinish() async {
        let store = NavigationStore(root: HomeRoute.feed)
        var calls = 0

        store.navigator.flow(ProofFlow()) { _ in calls += 1 }
        await settle()
        store.navigator.pop()
        await settle()

        #expect(calls == 0)
        #expect(store.currentSteps.isEmpty)
    }

    @Test func cancelFlowUnwindsAndReportsAbandoned() async {
        let store = NavigationStore(root: HomeRoute.feed)
        let nav = store.navigator

        async let proof = nav.flow(ProofFlow())
        await settle()
        nav.push(ProofStep.link)
        nav.cancelFlow()

        #expect(await proof == nil)
        #expect(store.currentSteps.isEmpty)
    }

    @Test func startStepPresentationRunsTheFlowInAModal() async {
        let store = NavigationStore(root: HomeRoute.feed)

        async let id = store.navigator.flow(RegistrationFlow())
        await settle()
        #expect(store.currentSteps == [.present(route: AnyRoute(RegistrationStep.team), style: .sheet)])

        store.navigator.finishFlow(returning: 42)
        #expect(await id == 42)
        #expect(store.currentSteps.isEmpty)
    }

    @Test func subflowResultContinuesTheParentFlow() async {
        let store = NavigationStore(root: HomeRoute.feed)
        let nav = store.navigator

        async let registration = nav.flow(RegistrationFlow())
        await settle()

        // The team step runs the proof flow and continues with its result.
        nav.flow(ProofFlow(required: false)) { proof in nav.push(RegistrationStep.summary(proof: proof)) }
        await settle()
        #expect(store.currentSteps == [
            .present(route: AnyRoute(RegistrationStep.team), style: .sheet),
            .push(ProofStep.upload(required: false)),
        ])

        nav.finishFlow(returning: "doc")
        await settle()
        #expect(store.currentSteps == [
            .present(route: AnyRoute(RegistrationStep.team), style: .sheet),
            .push(RegistrationStep.summary(proof: "doc")),
        ])

        nav.finishFlow(returning: 7)
        #expect(await registration == 7)
        #expect(store.currentSteps.isEmpty)
    }

    @Test func flowsCountAsHavingAScreen() {
        #expect(RouteRegistry().missingViews(for: [ProofFlow.self, ProofStep.self]) == [ProofStep.routeKey])
    }
}
