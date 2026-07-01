# Deep Linking

`NavigationKit` separates *parsing* a URL from *applying* it to a live navigator, so deep link
logic can be unit tested without any UI.

## URL segments

`URL.segments` flattens host and path components into an array, dropping slashes, which makes
deep link parsers easy to write as a `switch` over an array:

```swift
let url = URL(string: "myapp://schedule/session/42")!
url.segments // ["schedule", "session", "42"]
```

## Registering handlers

`DeeplinkResolver` holds an ordered list of parsers. Each parser receives a `URL` and may
return a `NavigationState` describing the target navigation tree; the first handler to return
non-`nil` wins.

```swift
let resolver = DeeplinkResolver()

resolver.register { url in
    guard url.segments.first == "schedule",
          url.segments.count >= 3,
          url.segments[1] == "session" else { return nil }

    let sessionID = url.segments[2]
    return TabsState(
        selection: AppTab.schedule,
        tabs: [
            AnyHashable(AppTab.schedule): StackState(ScheduleRoute.list)
                .pushing(ScheduleRoute.session(id: sessionID))
        ]
    ).asState
}
```

Register one handler per feature module — each handler only needs to know about its own
route types, not the app's full route surface.

## Resolving and applying

```swift
if let state = resolver.resolve(url) {
    applyDeepLink(state, to: appNavigator)
}
```

`applyDeepLink` checks that the resolved state's shape (`.stack` vs `.tabs` vs `.split`) matches
the target `RootNavigator`'s case before applying it; a mismatch is silently ignored rather than
crashing. This matters for apps whose root navigator shape varies by device — see
[Stacks, Tabs & Split Views](StacksAndTabs.md#split-navigators) — since a single handler can't
return a state that satisfies both a `.tabs` navigator on iPhone and a `.split` navigator on
iPad. `Examples/ShowCaseApp` handles this by branching inside each handler on whether the root
navigator is split:

```swift
resolver.register { [isSplit] url in
    guard let routes = ScheduleDeepLink.parse(url.segments) else { return nil }
    let stack = StackState(ScheduleRoute.list).pushing(all: Array(routes.dropFirst()))
    return isSplit
        ? SplitState(detail: stack).asState
        : TabsState(selection: AppTab.schedule, tabs: [AnyHashable(AppTab.schedule): stack]).asState
}
```

A typical app wires this into `onOpenURL`:

```swift
NavigationContainer(navigator: context.navigator, routeBuilder: context.routeBuilder)
    .onOpenURL { url in
        if let state = context.deeplinkResolver.resolve(url) {
            applyDeepLink(state, to: context.navigator)
        }
    }
```

## Deep linking into a modal

Because `StackState` can carry a `.sheet` or `.fullScreenCover` modal, a deep link can also open
a sheet directly:

```swift
resolver.register { url in
    guard url.segments.first == "account", url.segments.dropFirst().first == "settings"
    else { return nil }

    return TabsState(
        selection: AppTab.discover,
        tabs: [
            AnyHashable(AppTab.discover): StackState(DiscoverRoute.discover)
                .presentingSheet(.stack(StackState(AccountRoute.settings)))
        ]
    ).asState
}
```

See [State Snapshots & Restoration](StateSnapshots.md) for the full `StackState` / `TabsState` /
`SplitState` API used to build these trees.
