# Migration

## Migrating to 4.0

4.0 makes flows own their steps and settles the module names. The 3.x sections below already use the 4.0 names.

### Renames

| 3.x | 4.0 |
|---|---|
| `TypedRouteModule` | `RouteModule` |
| `RouteModule` (the general protocol) | `NavigationModule` |
| `body(for:nav:)` | `body(for:navigator:)` |
| `Remember(for:) { … } content: { … }` | `WithDependency(for:) { … } content: { … }` |

### Flows

A flow's steps move from a public route enum into the flow, and their screens into one `FlowModule`:

```swift
// 3.x
struct Checkout: Flow {
    typealias Result = Order
    var start: CheckoutRoute { .review }
}
enum CheckoutRoute: Route { case review, payment, done(Order) }
struct CheckoutScreens: TypedRouteModule {
    func body(for route: CheckoutRoute, nav: RouteNavigator<CheckoutRoute>) -> some View {
        switch route {
        case .review:          ReviewScreen(onNext: { nav.push(.payment) })
        case .payment:         PaymentScreen(onPaid: { nav.push(.done($0)) })
        case let .done(order): DoneScreen(onClose: { nav.finishFlow(returning: order) })
        }
    }
}

// 4.0
struct Checkout: Flow {
    typealias Result = Order
    enum Step: Hashable, Codable, Sendable { case review, payment, done(Order) }
    var start: Step { .review }
}
struct CheckoutScreens: FlowModule {
    func body(for step: Checkout.Step, in flow: Checkout, navigator: FlowNavigator<Checkout>) -> some View {
        switch step {
        case .review:          ReviewScreen(onNext: { navigator.next(.payment) })
        case .payment:         PaymentScreen(onPaid: { navigator.next(.done($0)) })
        case let .done(order): DoneScreen(onClose: { navigator.finish(order) })
        }
    }
}
```

| 3.x | 4.0 |
|---|---|
| step route enum (`Route`) | `Flow.Step` (`Hashable, Codable, Sendable`) |
| `nav.push(.step)` inside a flow | `navigator.next(.step)` |
| `nav.finishFlow(returning: value)` / `nav.finishFlow()` | `navigator.finish(value)` / `navigator.finish()` |
| `nav.cancelFlow()` | `navigator.cancel()` |
| `nav.flow(SomeRoute.first, returning: T.self)` | declare a `Flow`; `navigator.flow(SomeFlow())` |
| traits of the start step (`presentation`, `hidesTabBar`, `requiresAuth`) | traits of the `Flow` itself |

- Data a step needed from the flow's input no longer has to travel in payloads: read `flow.cart` in the module.
- `finish` is type-checked: a step can't hand back the wrong type any more.
- Unit tests: `FlowNavigator(RecordingNavigator(), flow: Checkout(…))`, then `recorder.steps(of: Checkout.self)`.

## Migrating to 3.0

3.0 removes `ViewRoute`. Routes are plain values everywhere and every screen comes from a module, so a route enum can always live in a package without SwiftUI. In exchange, flows become reusable building blocks: a `Flow` is a typed entry point that callers start — or run as a step of their own flow — without knowing its screens.

### `ViewRoute` → `RouteModule`

Same `switch`, moved into a module:

```swift
// 2.x
extension SpeakersRoute: ViewRoute {
    func body(_ navigator: RouteNavigator<Self>) -> some View {
        switch self { … }
    }
}

// 3.0
struct SpeakersModule: RouteModule {
    func body(for route: SpeakersRoute, navigator: RouteNavigator<SpeakersRoute>) -> some View {
        switch route { … }
    }
}
```

Then list the module at the root: `.routes(SpeakersModule())`. A route you forget shows the "unregistered route" placeholder; `RouteRegistry(appModules).missingViews(for:)` catches that in a test.

- `#Preview { route.preview() }` → `route.preview(using: SpeakersModule())`.
- `@ViewBuilder func body(_ navigator:)` helpers on nested step enums become their own `RouteModule`s; a feature can bundle them in one `NavigationModule` whose `register(in:)` calls `registry.add(…)` for each.

### Flows

Route-based flows keep working (`navigator.flow(CheckoutRoute.cart, returning: Order.self)`). To make one reusable, give it a `Flow`:

```swift
public struct Checkout: Flow {
    public typealias Result = Order
    public var start: CheckoutRoute { .cart }
}

navigator.flow(Checkout()) { order in … }            // was: navigator.flow(CheckoutRoute.cart, returning: Order.self) { order in }
```

- Steps that ended a flow with `pop(to:)` can call `navigator.cancelFlow()`.
- A step that pushed into another team's screens can run their flow instead:
  `navigator.flow(ProofFlow(…)) { proof in navigator.push(.summary(proof)) }`.
- `flow(_:as:)` and `flow(_:as:onFinish:)` for plain routes are now disfavored overloads, so a `Flow` always picks the typed form. A `Flow`'s `onFinish` runs only when it finishes.

## Migrating to 2.0

2.0 replaces the navigator classes with one protocol and a declarative root. Features get simpler; the app's composition root shrinks to a few lines.

### Concept map

| 1.x | 2.0 |
|---|---|
| `StackNavigator`, `TabsNavigator`, `SplitNavigator`, `AdaptiveNavigator`, `RootNavigator` | `NavigationRoot` + `.layout(…)`; features receive `any Navigator` / `RouteNavigator<R>` |
| `NavigationContainer(navigator:routeBuilder:)` | `NavigationRoot { RootSection… }` |
| `RouteBuilder.register(Type.self) { route, navigator in }` | `RouteModule` (3.0), or `NavigationModule` + `registry.register { (route: R, navigator) in }` |
| Routes: `Hashable` | Routes: `Route` (`Hashable`, `Codable`, `Sendable`) with optional traits |
| `present(sheet:)`, `present(fullScreenCover:)` | `present(_:as:)` with `.sheet`, `.sheet(detents:)`, `.cover`, `.popover`, `.inspector`, `.window` |
| `present(alert: AlertSpec(…))` | `await navigator.confirm(…)`, `alert`, `retry`, `dialog { … }` |
| `popTo(_:)` | `pop(to:) -> Bool` |
| `SplitNavigator.showDetail(_:)` | `show(_:)` (works in every layout) |
| Selecting tabs via `TabsNavigator` | `select(_:)` (works for tabs and sidebar) |
| `StackState`, `TabsState`, `SplitState`, `NavigationState` | `NavigationSnapshot` (`Codable`), `[Step]` |
| `DeeplinkResolver`, `applyDeepLink` | `DeepLinks` protocol / `.deepLinks { url in [Step] }` |
| Debugger window | `.navigationDebugger()` overlay + `onNavigationEvent` |
| Hand-written sidebar screen | Built in: sections render as a sidebar in split layouts |

### Step by step

1. **Routes**: change `: Hashable` to `: Route`. Nested payload enums need `Codable, Sendable`.
2. **Screens**: move each `RouteBuilder` registration into a `RouteModule` (same switch, `navigator` → `navigator`, leading-dot routes) and list the modules with `.routes(…)`.
3. **Modals**: `present(sheet: x)` → `present(x)` or a `presentation` trait + `open(x)`. Full-screen covers → `.cover`.
4. **Alerts**: replace `AlertSpec` buttons with an awaited `confirm`:
   ```swift
   // 1.x
   navigator.present(alert: AlertSpec(title: "Log out?", buttons: [
       .init("Log out", role: .destructive) { navigator.dismiss() }, .init("Cancel", role: .cancel)]))
   // 2.0
   Task { if await navigator.confirm("Log out?", confirm: "Log out", destructive: true) { navigator.dismiss() } }
   ```
5. **Wizards**: where a step does `popTo(.dashboard)` to finish, start the wizard with `navigator.flow(…)` and finish with `navigator.finishFlow()`.
6. **Root**: replace the navigator construction and any `isSplit` branching with `NavigationRoot { RootSection… }.layout(.adaptive)`. Delete your sidebar screen.
7. **Deep links**: return `[Step]` instead of navigator state. Use `.show` for items that belong in a detail column — the same steps work on iPhone and iPad.
8. **Restoration**: `.restoration(.sceneStorage("navigator"))`.

The ShowCase app in `Examples/` was migrated this way; its diff is a worked example.

### From plain `NavigationStack`

- `NavigationStack(path:)` + `.navigationDestination(for:)` → `NavigationRoot(rootRoute)` + a `RouteModule` passed to `.routes(…)`.
- `@State var isPresented` + `.sheet` → `navigator.present(route)`; the presented view calls `navigator.dismiss()`.
- `@Environment(\.dismiss)` still works inside presented screens; prefer `navigator.dismiss(returning:)` when you need to hand back a value.
- Adopt incrementally with `RouteLink` inside existing lists.
