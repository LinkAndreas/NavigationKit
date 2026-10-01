# Testing

## Screens and view models: `RecordingNavigator`

```swift
import NavigationKitTesting

@Test @MainActor func confirmingDeleteNavigatesBack() async {
    let nav = RecordingNavigator()
    nav.answerDialogs(with: "Delete")

    await DraftModel(nav: nav).delete()

    #expect(nav.dialogs.first?.title == "Delete draft?")
    #expect(nav.actions == [.pop])
}
```

Script async answers: `nav.results[AnyRoute(PickerRoute.color)] = Color.red` for `present(_:returning:)` and `flow`, and `nav.dialogResponse` for any dialog.

## Navigation behavior: a headless store

`NavigationStore` runs without views. Drive it with its navigator and assert where the user ended up:

```swift
@Test @MainActor func deepLinkOpensSession() async throws {
    let store = NavigationStore(layout: .tabs, sections: appSections)
    let steps = try #require(AppLinks.steps(for: URL(string: "myapp://schedule/session/42")!))

    await store.navigate(steps)

    #expect(store.currentSteps == [.select(AppTab.schedule), .push(ScheduleRoute.session(id: "42"))])
}
```

`currentSteps` speaks the same language as `navigate` and deep links, so assertions read like the navigation they test. `store.recentEvents` holds the last 100 events.
