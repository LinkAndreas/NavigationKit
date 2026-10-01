import Foundation
import Testing
@testable import NavigationKit

@MainActor
struct SectionTests {
    @Test func selectSwitchesSection() {
        let store = makeStore()
        store.navigator.select(AppTab.schedule)
        #expect(store.selection(as: AppTab.self) == .schedule)
        #expect(!store.navigator.perform(.select(AnySectionID(AppTab.account))))
    }

    @Test func showPushesInCompactLayout() {
        let store = makeStore(layout: .adaptive)
        store.setRegularWidth(false)
        store.navigator.select(AppTab.schedule)
        store.navigator.show(ScheduleRoute.session(id: "1"))
        #expect(store.currentSteps == [.select(AppTab.schedule), .push(ScheduleRoute.session(id: "1"))])
    }

    @Test func showTargetsDetailColumnInSplitLayout() {
        let store = makeStore(layout: .adaptive)
        store.setRegularWidth(true)
        store.navigator.select(AppTab.schedule)
        store.navigator.show(ScheduleRoute.session(id: "1"))
        #expect(store.currentSteps == [.select(AppTab.schedule), .show(ScheduleRoute.session(id: "1"))])

        // Pushing from the detail screen stays in the detail column.
        store.navigator.push(ScheduleRoute.speaker(id: "s"))
        #expect(store.currentSteps.last == .push(ScheduleRoute.speaker(id: "s")))
    }

    @Test func collapsingCarriesDetailOntoMainStack() {
        let store = makeStore(layout: .adaptive)
        store.setRegularWidth(true)
        store.navigator.select(AppTab.schedule)
        store.navigator.show(ScheduleRoute.session(id: "1"))

        store.setRegularWidth(false)
        #expect(store.currentSteps == [.select(AppTab.schedule), .push(ScheduleRoute.session(id: "1"))])
    }

    @Test func selectingWithModalOpenDismissesFirst() async {
        let store = makeStore()
        store.navigator.present(HomeRoute.profile(id: "1"))
        store.navigator.select(AppTab.schedule)
        await settle()
        #expect(store.currentSteps == [.select(AppTab.schedule)])
    }
}
