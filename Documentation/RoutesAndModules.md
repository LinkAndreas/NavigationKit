# Routes & Modules

## Routes

```swift
enum SpeakersRoute: Route {
    case overview, detail(id: String)
}
```

`Route` is `Hashable`, `Codable` and `Sendable`. `Codable` is synthesized for enums with codable payloads and is what makes restoration and Handoff work. A route's `routeKey` (default: module-qualified type name) identifies it in persisted data; override it if you rename the type.

Optional traits: `presentation`, `requiresAuth`, `hidesTabBar`.

## Routes that render themselves

When a feature owns its routes and screens, conform to `ViewRoute`:

```swift
extension SpeakersRoute: ViewRoute {
    func body(_ nav: RouteNavigator<Self>) -> some View {
        switch self {
        case .overview: SpeakerList(onSelect: { nav.push(.detail(id: $0)) })
        case let .detail(id): SpeakerDetail(id: id)
        }
    }
}
```

`RouteNavigator<Self>` is a navigator that knows your route type, which enables leading-dot syntax. Other features' routes still work: `nav.push(ScheduleRoute.list)`.

## Modules

Use a `RouteModule` when the route can't render itself:

- the route lives in a lightweight *contracts* package so other features can navigate to it without depending on its implementation, or
- its screens need dependencies the app provides.

```swift
public struct ScheduleModule: RouteModule {
    let avatars: AvatarProvider

    public var routeTypes: [any Route.Type] { [ScheduleRoute.self] }   // decodable before first use

    public func register(in registry: RouteRegistry) {
        registry.register { (route: ScheduleRoute, nav) in
            switch route {
            case .list: ScheduleView(onSelect: { nav.show(.session(id: $0)) })
            case let .session(id): SessionView(id: id, avatars: avatars)
            }
        }
    }
}

NavigationRoot { … }.routes(ScheduleModule(avatars: avatars), DiscoverModule())
```

Resolution order for every screen: a registered builder, then `ViewRoute.body`, then a visible "unregistered route" placeholder. Because the registry wins, the app can override a feature's screen.

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
#Preview { SpeakersRoute.detail(id: "s1").preview() }
#Preview { ScheduleRoute.list.preview(using: ScheduleModule.mock) }
```
