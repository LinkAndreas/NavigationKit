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

Screens come from modules. When a module covers one route type, conform to `TypedRouteModule`. Its screens are an exhaustive `switch`, so a new case without a screen is a compile error, and `register(in:)` and `routeTypes` come for free:

```swift
public struct ScheduleModule: TypedRouteModule {
    let avatars: AvatarProvider

    public func body(for route: ScheduleRoute, nav: RouteNavigator<ScheduleRoute>) -> some View {
        switch route {
        case .list: ScheduleView(onSelect: { nav.show(.session(id: $0)) })
        case let .session(id): SessionView(id: id, avatars: avatars)
        }
    }
}

NavigationRoot { … }.routes(ScheduleModule(avatars: avatars), DiscoverModule())
```

`RouteNavigator<ScheduleRoute>` is a navigator that knows your route type, which enables leading-dot syntax. Other features' routes still work: `nav.push(SpeakersRoute.list)`.

Call `.routes(…)` as often as you like — `.routes(CartModule()).routes(ProductModule())` equals `.routes(CartModule(), ProductModule())`.

### Several route types in one module

Conform to `RouteModule` and register each type, or add other modules — handy for a feature that ships one module for all its screens and flows:

```swift
public struct MyConfModule: RouteModule {
    public func register(in registry: RouteRegistry) {
        registry.add(MyConfScreens())                 // TypedRouteModules
        registry.add(CheckoutScreens())
        registry.register { (route: LegacyRoute, nav) in LegacyScreen(route) }
    }
}
```

A route without a registered screen shows a visible "unregistered route" placeholder. Registering a type again replaces its screens, so the app can override a feature's screen by listing its own module last.

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
public struct DiscoverModule<Schedule: Route>: RouteModule {
    let scheduleRoute: Schedule
    public func register(in registry: RouteRegistry) {
        registry.register { (route: DiscoverRoute, nav) in
            DiscoverScreen(openSchedule: { nav.push(scheduleRoute) })
        }
    }
}
```

## View models without SwiftUI

Depend on `NavigationKitInterface` and take a `Navigator`:

```swift
@Observable final class CheckoutModel {
    let nav: any Navigator
    func pay() async {
        guard await nav.confirm("Pay \(total)?") else { return }
        nav.finishFlow(returning: try? await api.pay())
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
