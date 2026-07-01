# Stacks, Tabs & Split Views

Every navigation hierarchy in `NavigationKit` is driven by one of three concrete navigator
classes — `StackNavigator`, `TabsNavigator`, or `SplitNavigator` — each owning only the state
its shape needs. `RootNavigator` is a thin enum over the three (`.stack`, `.tabs`, `.split`),
used wherever a caller needs to hold or render "a navigator" without committing to a shape up
front; `NavigationContainer` switches on it to render the right SwiftUI scaffolding.

## Stack navigators

A stack navigator owns a `root` route and a `path` of pushed routes, mirroring SwiftUI's
`NavigationStack`.

```swift
let navigator = StackNavigator(root: HomeRoute.feed)

navigator.push(HomeRoute.profile(id: "123"))   // push
navigator.pop()                                 // pop one
navigator.popToRoot()                           // clear path
navigator.popTo(HomeRoute.profile(id: "123"))   // pop back to a specific route, if present
```

`path` is a plain `[AnyRoute]`, so you can also read or mutate it directly — `@Observable`
ensures SwiftUI re-renders the bound `NavigationStack`.

## Tab navigators

A tabs navigator hosts a `TabsNavigator.Tab` per tab, each wrapping its **own** `StackNavigator`.
This means every tab keeps an independent push history.

```swift
let appNavigator = TabsNavigator(
    tabs: [
        TabsNavigator.Tab(id: AppTab.discover, title: "Discover", systemImage: "sparkles",
                      navigator: StackNavigator(root: DiscoverRoute.discover)),
        TabsNavigator.Tab(id: AppTab.schedule, title: "Schedule", systemImage: "calendar",
                      navigator: StackNavigator(root: ScheduleRoute.list)),
    ],
    selection: AppTab.discover
)

appNavigator.select(AppTab.schedule)
let scheduleNavigator = appNavigator.navigator(for: AppTab.schedule)
scheduleNavigator?.push(ScheduleRoute.session(id: "42"))
```

`Tab.id` accepts any `Hashable`, so it's idiomatic to model tabs with your own enum (as above)
rather than raw strings.

## Split navigators

A split navigator drives a `NavigationSplitView`. It hosts a `sidebar` `StackNavigator`, an
optional `content` `StackNavigator` (for three-column layouts), and a `detail` `StackNavigator`
— each with its own independent push history, just like a tab.

```swift
let sidebarNavigator = StackNavigator(root: InboxRoute.sidebar)
let detailNavigator = StackNavigator(root: InboxRoute.emptyDetail)

let splitNavigator = SplitNavigator(
    sidebar: sidebarNavigator,
    detail: detailNavigator,
    columnVisibility: .automatic
)
```

React to a sidebar selection by replacing the detail column's root (this also clears any
routes pushed on top of the previous detail):

```swift
splitNavigator.showDetail(InboxRoute.message(id: "42"))
```

For a three-column layout, pass a `content` navigator too and use `showContent(_:)` the same way.
`columnVisibility` is a plain `SplitVisibility` enum (`.automatic`, `.all`, `.doubleColumn`,
`.detailOnly`) that `SplitContainer` maps to SwiftUI's `NavigationSplitViewVisibility`; set it
directly on the navigator to collapse or expand columns.

## Rendering

`NavigationContainer` is the single entry point for rendering a navigator, regardless of shape.
It takes a `RootNavigator`, so wrap whichever concrete navigator you built in the matching case:

```swift
NavigationContainer(navigator: .tabs(appNavigator), routeBuilder: routeBuilder)
```

Internally it switches on the `RootNavigator` case and delegates to `StackContainer` (wraps
`NavigationStack`), `TabsContainer` (wraps `TabView`), or `SplitContainer` (wraps
`NavigationSplitView`). Because tabs and split columns hold their own child `StackNavigator`,
and sheets/full screen covers do too (see [Modals](Modals.md)), `NavigationContainer` is applied
recursively — a tab can contain a stack, which can present a sheet, which contains its own
stack, and so on.

## Routes

Routes are plain `Hashable` values, typically one enum per feature module:

```swift
enum ScheduleRoute: Hashable {
    case list
    case session(id: String)
}
```

`AnyRoute` type-erases a route for storage in `path`, while preserving `Hashable` semantics
(so `popTo` and equality checks work as expected). You won't normally construct `AnyRoute`
yourself — `push`, `popTo`, and the navigator initializers wrap routes for you.

## View registration

`RouteBuilder` maps a route type to the view that renders it. Register routes once, typically
at app startup, grouped by feature:

```swift
let routeBuilder = RouteBuilder()

routeBuilder.register(ScheduleRoute.self) { route, navigator in
    switch route {
    case .list:
        ScheduleListScreen(navigator: navigator)
    case let .session(id):
        SessionDetailScreen(sessionID: id, navigator: navigator)
    }
}
```

Each registered builder receives the route value and the `StackNavigator` that owns it, so the
destination view can push further routes, present modals, or read stack state without any
extra wiring. An unregistered route renders a visible red error view instead of crashing —
useful for catching missing registrations during development.
