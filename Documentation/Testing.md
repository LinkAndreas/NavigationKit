# Testing

## Screens and view models: `RecordingNavigator`

```swift
import NavigationKitTesting

@Test @MainActor func confirmingDeleteNavigatesBack() async {
    let navigator = RecordingNavigator()
    navigator.answerDialogs(with: "Delete")

    await DraftModel(navigator: navigator).delete()

    #expect(navigator.dialogs.first?.title == "Delete draft?")
    #expect(navigator.actions == [.pop])
}
```

Script async answers: `navigator.results[AnyRoute(PickerRoute.color)] = Color.red` for `present(_:returning:)` and `flow`, and `navigator.dialogResponse` for any dialog.

A flow's screens get a `FlowNavigator`; build one on a recorder and check which steps it showed and how it finished:

```swift
@Test @MainActor func payingFinishesCheckout() {
    let recorder = RecordingNavigator()
    let navigator = FlowNavigator(recorder, flow: Checkout(cart: .sample))

    PaymentModel(navigator: navigator).didPay(order: .sample)

    #expect(recorder.steps(of: Checkout.self) == [.done(.sample)])        // shown with next(_:)
    #expect(recorder.actions.last == .finishFlow(result: Order.sample))   // or .finishFlow(result: nil) for cancel()
}
```

`remember(for:)` keeps values per lifetime until you end it:

```swift
let first = navigator.remember(for: .flow) { CheckoutSession() }
#expect(navigator.remember(for: .flow) { CheckoutSession() } === first)

navigator.end(.flow)                                           // as if the run had finished
#expect(navigator.remember(for: .flow) { CheckoutSession() } !== first)
```

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

## Every route has a screen

```swift
@Test @MainActor func everyRouteHasAScreen() {
    let registry = RouteRegistry(AppComposition.modules)
    #expect(registry.missingViews(for: [ScheduleRoute.self, SpeakersRoute.self]).isEmpty)
}
```

See [Routes & Modules](RoutesAndModules.md#checking-that-every-route-has-a-screen).
