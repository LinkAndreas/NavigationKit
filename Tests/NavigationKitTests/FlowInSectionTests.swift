import Foundation
import Testing
@testable import NavigationKit

private final class Session {}

@MainActor
struct FlowInSectionTests {
    private func makeStore(onFinish: (@MainActor (String) -> Void)? = nil) -> NavigationStore {
        NavigationStore(layout: .tabs, selection: AppTab.home, sections: [
            RootSection(AppTab.home, "Proof", icon: "doc", flow: ProofFlow(), onFinish: onFinish),
            RootSection(AppTab.schedule, "Schedule", icon: "calendar") { ScheduleRoute.list },
        ])
    }

    @Test func aTabShowsItsFlowsFirstStep() {
        let store = makeStore()
        #expect(store.sections[0].main.rootEntry.route.as(FlowStepRoute<ProofFlow>.self)?.step == .upload(required: true))
    }

    @Test func finishingStartsTheFlowOverAndReportsTheResult() {
        var results: [String] = []
        let store = makeStore { results.append($0) }
        let firstRun = flowNavigator(store, ProofFlow.self).run

        flowNavigator(store, ProofFlow.self).next(.link)
        flowNavigator(store, ProofFlow.self).finish("repo")

        #expect(results == ["repo"])
        #expect(store.sections[0].main.path.isEmpty)
        #expect(store.sections[0].main.rootEntry.route.as(FlowStepRoute<ProofFlow>.self)?.step == .upload(required: true))
        #expect(flowNavigator(store, ProofFlow.self).run != firstRun)          // a fresh run
    }

    @Test func cancellingStartsOverWithoutAResult() {
        var results: [String] = []
        let store = makeStore { results.append($0) }

        flowNavigator(store, ProofFlow.self).next(.link)
        flowNavigator(store, ProofFlow.self).cancel()

        #expect(results.isEmpty)
        #expect(store.sections[0].main.path.isEmpty)
    }

    @Test func eachRunOfATabsFlowGetsFreshDependencies() {
        let store = makeStore()
        let nav = store.navigator
        weak var firstRun: Session?

        do {
            let session = nav.remember(for: .flow) { Session() }
            flowNavigator(store, ProofFlow.self).next(.link)
            #expect(nav.remember(for: .flow) { Session() } === session)
            firstRun = session
        }
        flowNavigator(store, ProofFlow.self).finish("done")

        #expect(firstRun == nil)
    }

    @Test func aSingleRootFlowStartsOverToo() {
        let store = NavigationStore(root: ProofFlow())
        flowNavigator(store, ProofFlow.self).next(.link)
        flowNavigator(store, ProofFlow.self).finish("done")

        #expect(store.currentSteps.isEmpty)
        #expect(shownSteps(store, ProofFlow.self) == [])                       // only the root step is left
        #expect(store.sections[0].main.rootEntry.route.as(FlowStepRoute<ProofFlow>.self) != nil)
    }

    @Test func aTabsFlowProgressIsRestored() async throws {
        let original = makeStore()
        flowNavigator(original, ProofFlow.self).next(.link)
        let data = try JSONEncoder().encode(original.snapshot)

        let restored = makeStore()
        await restored.restore(try JSONDecoder().decode(NavigationSnapshot.self, from: data))

        #expect(restored.sections[0].main.path.count == 1)
        flowNavigator(restored, ProofFlow.self).finish("restored")         // still one run
        #expect(restored.sections[0].main.path.isEmpty)
    }

    @Test func aFlowAsDefaultDetailIsNotACustomizedDetail() {
        let store = NavigationStore(layout: .split, selection: AppTab.schedule, sections: [
            RootSection(AppTab.schedule, "Schedule", icon: "calendar") { ScheduleRoute.list } detail: { ProofFlow() },
        ])

        #expect(store.sections[0].detailIsCustomized == false)
    }
}
