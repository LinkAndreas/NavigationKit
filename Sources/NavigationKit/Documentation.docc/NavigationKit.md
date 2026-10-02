# ``NavigationKit``

Layout-agnostic, state-driven navigation for SwiftUI.

## Overview

Every screen receives a `Navigator` scoped to where it is. It pushes, presents, shows, selects and dismisses without knowing whether it's in a tab, a sidebar, a sheet or a window; ``NavigationRoot`` builds the right containers around it. Navigation state is plain `Codable` data — deep links, restoration, Handoff and tests all use the same `Step` language.

```swift
NavigationRoot(selection: AppTab.discover) {
    RootSection(AppTab.discover, "Discover", icon: "sparkles") { DiscoverRoute.home }
    RootSection(AppTab.schedule, "Schedule", icon: "calendar") { ScheduleRoute.list }
}
.layout(.adaptive)
.routes(DiscoverModule(), ScheduleModule())
.deepLinks(AppLinks.self)
.restoration(.sceneStorage("nav"))
```

## Topics

### Essentials

- <doc:GettingStarted>
- ``NavigationRoot``
- ``RootSection``
- ``NavigationLayout``

### Routes and screens

- ``TypedRouteModule``
- ``RouteModule``
- ``RouteRegistry``
- ``RouteLink``

### Navigating

Screens navigate through `Navigator` (and its typed form `RouteNavigator`), presenting with a
`PresentationStyle`, asking with a `Dialog`, describing paths as `Step`s and composing processes as
`Flow`s. These types live in
`NavigationKitInterface`, which `NavigationKit` re-exports.

### State

- ``NavigationStore``
- ``NavigationSnapshot``
- ``Restoration``
