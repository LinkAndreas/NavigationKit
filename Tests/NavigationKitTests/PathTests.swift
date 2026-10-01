import Foundation
import Testing
@testable import NavigationKit

@MainActor
struct NavigateTests {
    @Test func navigateBuildsFullPathFromRoot() async {
        let store = makeStore()
        store.navigator.push(HomeRoute.profile(id: "old"))

        await store.navigate([
            .select(AppTab.schedule),
            .push(ScheduleRoute.session(id: "42")),
            .present(HomeRoute.profile(id: "1")),
            .push(ScheduleRoute.speaker(id: "s")),
        ])

        #expect(store.currentSteps == [
            .select(AppTab.schedule),
            .push(ScheduleRoute.session(id: "42")),
            .present(route: AnyRoute(HomeRoute.profile(id: "1")), style: .sheet),
            .push(ScheduleRoute.speaker(id: "s")),
        ])
    }

    @Test func sameStepsWorkInEveryLayout() async {
        for (layout, regular) in [(NavigationLayout.tabs, false), (.adaptive, true), (.adaptive, false)] {
            let store = makeStore(layout: layout)
            store.setRegularWidth(regular)
            await store.navigate([.select(AppTab.schedule), .show(ScheduleRoute.session(id: "1"))])
            #expect(store.selection(as: AppTab.self) == .schedule)
            #expect(store.currentSteps.count == 2)
        }
    }

    @Test func deepLinksResolveThroughHandler() async {
        let store = makeStore()
        store.deepLinkHandler = { url in
            guard url.segments.first == "session", let id = url.segments.last else { return nil }
            return [.select(AppTab.schedule), .push(ScheduleRoute.session(id: id))]
        }

        #expect(store.open(URL(string: "app://session/7")!))
        await settle()
        #expect(store.currentSteps == [.select(AppTab.schedule), .push(ScheduleRoute.session(id: "7"))])
        #expect(!store.open(URL(string: "app://unknown")!))
    }

    @Test func eventsStreamReportsNavigation() async {
        let store = NavigationStore(root: HomeRoute.feed)
        let events = store.events()
        store.navigator.push(HomeRoute.profile(id: "1"))

        var iterator = events.makeAsyncIterator()
        let first = await iterator.next()
        #expect(first?.description == NavigationEvent.pushed(AnyRoute(HomeRoute.profile(id: "1"))).description)
    }
}

@MainActor
struct SnapshotTests {
    @Test func snapshotRoundTrips() async throws {
        let store = makeStore()
        await store.navigate([.select(AppTab.schedule), .push(ScheduleRoute.session(id: "1")), .present(HomeRoute.profile(id: "2"))])

        let data = try JSONEncoder().encode(store.snapshot)
        let restored = makeStore()
        await restored.restore(try JSONDecoder().decode(NavigationSnapshot.self, from: data))

        #expect(restored.currentSteps == store.currentSteps)
    }

    @Test func undecodableRouteTruncatesInsteadOfFailing() throws {
        _ = AnyRoute(HomeRoute.feed)
        let json = """
        {"version":1,"selection":0,"sections":[{"main":{
            "root":{"type":"\(HomeRoute.routeKey)","value":{"feed":{}}},
            "path":[
                {"type":"\(HomeRoute.routeKey)","value":{"profile":{"id":"1"}}},
                {"type":"Removed.Route","value":{}},
                {"type":"\(HomeRoute.routeKey)","value":{"profile":{"id":"3"}}}
            ],
            "modals":[]
        }}, {"garbage":true}]}
        """
        let snapshot = try JSONDecoder().decode(NavigationSnapshot.self, from: Data(json.utf8))
        #expect(snapshot.sections[0]?.main.path == [AnyRoute(HomeRoute.profile(id: "1"))])
        #expect(snapshot.sections[1] == nil)
    }
}
