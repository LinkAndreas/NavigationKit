import Foundation
import SwiftUI
import Testing
import NavigationKitTesting
@testable import NavigationKit

private struct ProofScreens: FlowModule {
    func body(for step: ProofFlow.Step, in flow: ProofFlow, navigator: FlowNavigator<ProofFlow>) -> some View {
        switch step {
        case .upload: Button("Next") { navigator.next(.link) }
        case .link: Button("Done") { navigator.finish("repo") }
        }
    }
}

@MainActor
struct ComposedFlowTests {
    @Test func flowShowsItsFirstStepAndReturnsATypedResult() async {
        let store = NavigationStore(root: HomeRoute.feed)

        async let proof = store.navigator.flow(ProofFlow())
        await settle()
        #expect(shownSteps(store, ProofFlow.self) == [.upload(required: true)])

        flowNavigator(store, ProofFlow.self).next(.link)
        #expect(shownSteps(store, ProofFlow.self) == [.upload(required: true), .link])

        flowNavigator(store, ProofFlow.self).finish("repo-url")
        #expect(await proof == "repo-url")
        #expect(store.currentSteps.isEmpty)
    }

    @Test func everyStepSeesTheFlowsInput() async {
        let store = NavigationStore(root: HomeRoute.feed)
        store.navigator.flow(ProofFlow(required: false)) { _ in }
        await settle()
        flowNavigator(store, ProofFlow.self).next(.link)

        #expect(flowNavigator(store, ProofFlow.self).flow.required == false)
    }

    @Test func voidFlowFinishes() async {
        let store = NavigationStore(root: HomeRoute.feed)
        var finished = false

        store.navigator.flow(OnboardingFlow()) { finished = true }
        await settle()
        flowNavigator(store, OnboardingFlow.self).next(.permissions)
        flowNavigator(store, OnboardingFlow.self).finish()
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

    @Test func cancelUnwindsAndReportsAbandoned() async {
        let store = NavigationStore(root: HomeRoute.feed)

        async let proof = store.navigator.flow(ProofFlow())
        await settle()
        flowNavigator(store, ProofFlow.self).next(.link)
        flowNavigator(store, ProofFlow.self).cancel()

        #expect(await proof == nil)
        #expect(store.currentSteps.isEmpty)
    }

    @Test func aFlowsPresentationRunsItInAModal() async {
        let store = NavigationStore(root: HomeRoute.feed)

        async let id = store.navigator.flow(RegistrationFlow())
        await settle()
        guard case .present(_, .sheet) = store.currentSteps.first else {
            Issue.record("expected the flow in a sheet, got \(store.currentSteps)")
            return
        }

        flowNavigator(store, RegistrationFlow.self).finish(42)
        #expect(await id == 42)
        #expect(store.currentSteps.isEmpty)
    }

    @Test func aStepRunsAnotherFlowAndContinuesWithItsResult() async {
        let store = NavigationStore(root: HomeRoute.feed)

        async let registration = store.navigator.flow(RegistrationFlow())
        await settle()

        let team = flowNavigator(store, RegistrationFlow.self)
        team.flow(ProofFlow(required: false)) { proof in team.next(.summary(proof: proof)) }
        await settle()
        #expect(shownSteps(store, ProofFlow.self) == [.upload(required: false)])

        flowNavigator(store, ProofFlow.self).finish("doc")
        await settle()
        #expect(shownSteps(store, ProofFlow.self).isEmpty)
        #expect(shownSteps(store, RegistrationFlow.self) == [.team, .summary(proof: "doc")])

        flowNavigator(store, RegistrationFlow.self).finish(7)
        #expect(await registration == 7)
        #expect(store.currentSteps.isEmpty)
    }

    @Test func finishingFromAScreenPushedByAStepEndsTheFlow() async {
        let store = NavigationStore(root: HomeRoute.feed)
        async let proof = store.navigator.flow(ProofFlow())
        await settle()

        store.navigator.push(HomeRoute.profile(id: "help"))   // a plain screen inside the flow
        store.navigator.perform(.finishFlow(result: "from help"))

        #expect(await proof == "from help")
        #expect(store.currentSteps.isEmpty)
    }

    @Test func aDeepLinkedFlowFinishesToo() async {
        let store = NavigationStore(root: HomeRoute.feed)
        await store.navigate([.push(HomeRoute.profile(id: "1")), .push(ProofFlow())])
        #expect(shownSteps(store, ProofFlow.self) == [.upload(required: true)])

        flowNavigator(store, ProofFlow.self).next(.link)
        flowNavigator(store, ProofFlow.self).finish("nobody waits")

        #expect(store.currentSteps == [.push(HomeRoute.profile(id: "1"))])
    }

    @Test func aRestoredFlowKeepsItsStepsAndFinishes() async throws {
        let original = NavigationStore(root: HomeRoute.feed)
        original.navigator.flow(ProofFlow(required: false)) { _ in }
        await settle()
        flowNavigator(original, ProofFlow.self).next(.link)

        let data = try JSONEncoder().encode(original.snapshot)
        let restored = NavigationStore(root: HomeRoute.feed)
        await restored.restore(try JSONDecoder().decode(NavigationSnapshot.self, from: data))

        #expect(shownSteps(restored, ProofFlow.self) == [.upload(required: false), .link])
        #expect(flowNavigator(restored, ProofFlow.self).flow.required == false)

        flowNavigator(restored, ProofFlow.self).finish("restored")
        #expect(restored.currentSteps.isEmpty)
    }

    @Test func aFlowCountsAsHavingScreensOnceItsModuleIsRegistered() {
        #expect(RouteRegistry().missingViews(for: [ProofFlow.self]) == [ProofFlow.routeKey])
        #expect(RouteRegistry([ProofScreens()]).missingViews(for: [ProofFlow.self]).isEmpty)
    }

    @Test func recordingNavigatorListsTheStepsAFlowShowed() {
        let recorder = RecordingNavigator()
        let navigator = FlowNavigator(recorder, flow: ProofFlow())

        navigator.next(.link)
        navigator.finish("repo")

        #expect(recorder.steps(of: ProofFlow.self) == [.link])
        #expect(recorder.actions.last == .finishFlow(result: "repo"))
    }
}
