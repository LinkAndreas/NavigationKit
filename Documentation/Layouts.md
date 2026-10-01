# Layouts

`NavigationRoot` renders the same navigation tree in four layouts. Screens never branch on which one is active.

| Layout | Renders | Default for |
|---|---|---|
| `.stack` | The selected section's `NavigationStack` | `NavigationRoot(route)` |
| `.tabs` | `TabView` with one stack per section | — |
| `.split` | `NavigationSplitView`: sidebar of sections, then the section's stack (and its detail column) | — |
| `.adaptive` | `.tabs` in compact width, `.split` in regular width, switching live | `NavigationRoot { sections }` |

## Single stack

```swift
NavigationRoot(HomeRoute.feed)
```

## Sections

```swift
NavigationRoot(selection: AppTab.schedule) {
    RootSection(AppTab.discover, "Discover", icon: "sparkles") { DiscoverRoute.home }
    RootSection(AppTab.schedule, "Schedule", icon: "calendar") {
        ScheduleRoute.list
    } detail: {
        ScheduleRoute.placeholder
    }
}
.layout(.adaptive)
```

A section's id is any `Hashable & Sendable` value — usually an enum. It is what `nav.select(_:)`, `Step.select(_:)` and `store.selection(as:)` use. Titles are `LocalizedStringResource`s, so string literals are looked up in your string catalog.

Sections can be built from data too: `RootSectionsBuilder` accepts `if`, `for` and arrays of `RootSection`.

## The detail column and `show`

A section with a `detail:` gets a three-column split view in regular width: sidebar, the section's main stack, and a detail stack starting at the placeholder route.

`nav.show(route)` expresses "display this item":

- In a split layout it **replaces** the detail column with `route`. Pushes from a detail screen stay in the detail column.
- In compact width (or a section without detail) it **pushes** onto the current stack.

When an adaptive layout collapses from split to tabs (an iPad app moving into Slide Over, say), whatever the detail column showed is carried onto the main stack, so the user keeps their place.

## Hiding the tab bar

Give a route the `hidesTabBar` trait:

```swift
var hidesTabBar: Bool { if case .player = self { true } else { false } }
```

## Programmatic access

Hold the store yourself when code outside the view hierarchy navigates:

```swift
@State private var store = NavigationStore(selection: AppTab.discover, sections: appSections)

var body: some View { NavigationRoot(store: store) }

func handle(_ notification: UNNotification) {
    store.navigator.push(ScheduleRoute.session(id: notification.sessionID))
}
```

`store.navigator` always acts on whatever is currently visible — the topmost modal of the selected section, or its detail column.
