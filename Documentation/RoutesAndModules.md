# Routes & Modules

## Routes

```swift
enum SpeakersRoute: Route {
    case overview, detail(id: String)
}
```

`Route` is `Hashable`, `Codable` and `Sendable`. `Codable` is synthesized for enums with codable payloads and is what makes restoration and Handoff work. A route's `routeKey` (default: module-qualified type name) identifies it in persisted data; override it if you rename the type.

Optional traits: `presentation`, `requiresAuth`, `hidesTabBar`.

Routes never contain views. That keeps them in `NavigationKitInterface` territory: a route enum can live in a lightweight *contracts* package that other features import to navigate to it, without depending on its screens.

## Modules

Screens come from modules, in three kinds:

| Module | Provides |
|---|---|
| `RouteModule` | the screens for one route type, as one exhaustive `switch` |
| `FlowModule` | the screens for one flow's steps — see [Flows](FlowsGuardsAndAuth.md#flows) |
| `NavigationModule` | anything else: several types, bundling other modules, custom registration |

`RouteModule` and `FlowModule` are `NavigationModule`s; `.routes(…)` takes any of them.

When a module covers one route type, conform to `RouteModule`. Its screens are an exhaustive `switch`, so a new case without a screen is a compile error, and `register(in:)` and `routeTypes` come for free:

```swift
public struct ScheduleModule: RouteModule {
    let avatars: AvatarProvider

    public func body(for route: ScheduleRoute, navigator: RouteNavigator<ScheduleRoute>) -> some View {
        switch route {
        case .list: ScheduleView(onSelect: { navigator.show(.session(id: $0)) })
        case let .session(id): SessionView(id: id, avatars: avatars)
        }
    }
}

NavigationRoot { … }.routes(ScheduleModule(avatars: avatars), DiscoverModule())
```

`RouteNavigator<ScheduleRoute>` is a navigator that knows your route type, which enables leading-dot syntax. Other features' routes still work: `navigator.push(SpeakersRoute.list)`.

Call `.routes(…)` as often as you like — `.routes(CartModule()).routes(ProductModule())` equals `.routes(CartModule(), ProductModule())`.

### Several route types in one module

Conform to `NavigationModule` and register each type, or add other modules — handy for a feature that ships one module for all its screens and flows:

```swift
public struct MyConfModule: NavigationModule {
    public func register(in registry: RouteRegistry) {
        registry.add(MyConfScreens())                 // a RouteModule
        registry.add(CheckoutScreens())               // a FlowModule
        registry.register { (route: LegacyRoute, navigator) in LegacyScreen(route) }
    }
}
```

A route without a registered screen shows a visible "unregistered route" placeholder. Registering a type again replaces its screens, so the app can override a feature's screen by listing its own module last.

## Dependencies and their lifetime

Screens get their dependencies through plain initializers, from the module. The module decides how long each one lives with `remember(for:)`:

```swift
struct CheckoutScreens: FlowModule {
    func body(for step: Checkout.Step, in flow: Checkout, navigator: FlowNavigator<Checkout>) -> some View {
        let api     = navigator.remember(for: .window) { CheckoutAPI() }
        let session = navigator.remember(for: .flow)   { CheckoutSession(api: api, cart: flow.cart) }

        switch step {
        case .review:  ReviewScreen(session: session, onNext: { navigator.next(.payment) })
        case .payment: PaymentScreen(session: session, onPaid: { navigator.finish($0) })
        }
    }
}
```

The rules:

1. A value is created the first time it's asked for — never up front.
2. Within one lifetime, every ask for the same type returns the same value.
3. When the lifetime ends, the value is released; the next run starts fresh.

| Lifetime | Created | Released |
|---|---|---|
| `.screen` | when this screen first asks | when the screen leaves its stack |
| `.flow` | when the first screen of a flow run asks | when the run finishes, is cancelled or backed out of |
| `.flow(Checkout.self)` | like `.flow`, for that enclosing flow — also from inside a nested one | when that flow's run ends |
| `.window` | when the first screen asks | when the `NavigationRoot` goes away (normally one per window) |

Outside a flow, `.flow` means the screen. Values are told apart by type: to keep two values of the same type, wrap them in distinct types. If the compiler can't infer the type from the closure — for example one with several statements — annotate it: `let api: CheckoutAPI = navigator.remember(for: .window) { … }`.

A screen that leaves its stack keeps its values while it animates out; they're released once, when its view is gone.

### As a view: `WithDependency`

`WithDependency` does the same in view form. Nesting wrappers makes the composition visible where screens are wired, and screens still get plain values:

```swift
case .review:
    WithDependency(for: .window) { CheckoutAPI() } content: { api in
        WithDependency(for: .flow) { CheckoutSession(api: api, cart: flow.cart) } content: { session in
            ReviewScreen(session: session, onNext: { navigator.next(.payment) })
        }
    }
```

It uses the navigator of the screen it's in, so it keeps values inside screens NavigationKit shows. In a bare preview, `make` runs on every render.

Rewiring is one word: `.screen`, `.flow` or `.window`. For a dependency that only part of a flow needs, make that part its own `Flow` — `.flow` inside it then means just that part.

The feature owns all of this; the app only lists `CheckoutScreens()`. Calling `remember` in `body` is safe: `body` runs on every render, and every call after the first returns the same value.

### Checking that every route has a screen

The compiler can't see across modules whether every route you navigate to has a screen, so make it a test. `missingViews(for:)` lists the route types without a registered screen (a `Flow` counts as covered — list its step type):

```swift
@Test @MainActor func everyRouteHasAScreen() {
    let registry = RouteRegistry(AppComposition.modules)     // the modules passed to .routes(…)
    #expect(registry.missingViews(for: [ScheduleRoute.self, SpeakersRoute.self, CheckoutRoute.self]).isEmpty)
}
```

A module you forgot to pass to `.routes(…)` then fails CI instead of showing the placeholder to users.

### Navigating across features without importing them

Inject destination routes into the module:

```swift
public struct DiscoverModule<Schedule: Route>: NavigationModule {
    let scheduleRoute: Schedule
    public func register(in registry: RouteRegistry) {
        registry.register { (route: DiscoverRoute, navigator) in
            DiscoverScreen(openSchedule: { navigator.push(scheduleRoute) })
        }
    }
}
```

## View models without SwiftUI

Depend on `NavigationKitInterface` and take a `Navigator`:

```swift
@Observable final class PaymentModel {
    let navigator: FlowNavigator<Checkout>       // also SwiftUI-free
    func pay() async {
        guard await navigator.confirm("Pay \(total)?") else { return }
        if let order = try? await api.pay() { navigator.finish(order) }
    }
}
```

Inside the view tree, `@Environment(\.navigator)` gives you the screen's navigator.

## `RouteLink`

For native link behavior (row chevrons, selection highlight) or gradual adoption:

```swift
List(speakers) { speaker in
    RouteLink(SpeakersRoute.detail(id: speaker.id)) { SpeakerRow(speaker) }
}
```

`NavigationLink(value:)` with your own values does **not** work inside NavigationKit stacks — their path is NavigationKit's. View-destination links (`NavigationLink { DetailView() }`) still work but aren't restorable.

## Previews

```swift
#Preview { SpeakersRoute.detail(id: "s1").preview(using: SpeakersModule()) }
#Preview { ScheduleRoute.list.preview(using: ScheduleModule.mock) }
```
