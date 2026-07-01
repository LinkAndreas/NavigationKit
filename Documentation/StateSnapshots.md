# State Snapshots & Restoration

`StackState`, `TabsState`, and `SplitState` describe a navigation tree as plain, `Equatable`
data — independent of any live navigator. They're the building blocks for deep linking (see
[Deep Linking](DeepLinking.md)) and can equally be used for persisting and restoring navigation
state across launches.

## `StackState`

```swift
let state = StackState(HomeRoute.feed)
    .pushing(HomeRoute.profile(id: "123"))
    .presentingSheet(.stack(StackState(SettingsRoute.root)))
```

- `root` — the bottom of the stack.
- `path` — routes pushed on top of `root`, built fluently with `pushing(_:)` / `pushing(all:)`.
- `modal` — an optional `.sheet` or `.fullScreenCover`, each wrapping another `NavigationState`.

`asState` wraps a `StackState` into the generic `NavigationState.stack` case so it can be passed
to `applyDeepLink` or stored inside a `TabsState`.

## `TabsState`

```swift
let state = TabsState(
    selection: AppTab.schedule,
    tabs: [
        AnyHashable(AppTab.schedule): StackState(ScheduleRoute.list)
            .pushing(ScheduleRoute.session(id: "42"))
    ]
)
```

`tabs` only needs to contain the tabs you actually want to update — `TabsNavigator.apply(_:)`
leaves any tab not present in the dictionary untouched. `selection` is optional for the same
reason: `nil` means "don't change the selected tab."

## `SplitState`

```swift
let state = SplitState(
    sidebar: StackState(InboxRoute.sidebar),
    detail: StackState(InboxRoute.message(id: "42")),
    columnVisibility: .doubleColumn
)
```

- `sidebar` / `content` / `detail` — each an optional `StackState` for that column.
  `SplitNavigator.apply(_:)` leaves a column untouched if its state is `nil`.
- `columnVisibility` — an optional `SplitVisibility`; `nil` means "don't change the current
  visibility."
- `modal` — same as `StackState`, an optional `.sheet` or `.fullScreenCover`.

## Applying a snapshot to a live navigator

```swift
stackNavigator.apply(stackState)
tabsNavigator.apply(tabsState)
splitNavigator.apply(splitState)
```

Or, when you don't know the navigator's shape ahead of time (e.g. resolving an arbitrary deep
link, so you're holding a `RootNavigator`), use the free function instead, which checks the
shapes match before applying:

```swift
applyDeepLink(state, to: navigator)
```

Applying a snapshot replaces `root`/`path` (or each tab's stack, or the sidebar/content/detail
columns of a split navigator), dismisses any *currently presented* modal, and then — after a
brief delay if a modal had to be dismissed first, to let SwiftUI's dismissal animation settle —
presents the modal described by the new state, if any.

## Reading state back out

None of the navigator types currently expose a method to capture their *own* state as a
`StackState` / `TabsState` / `SplitState` snapshot — `apply` is one-directional (data → live
navigator). If your app needs to persist the current navigation state, build the snapshot from
the same data you used to drive navigation in the first place (e.g. mirror route pushes into
your own persisted state), or read `stackNavigator.root`/`.path`, `tabsNavigator.tabs`/
`.selection`, and `splitNavigator.sidebar`/`.content`/`.detail` directly to construct one.

## Debugging the live tree

`StackNavigator`, `TabsNavigator`, `SplitNavigator`, and `RootNavigator` all conform to
`CustomDebugStringConvertible` and print a readable, indented summary of the entire tree —
stacks, tabs, split columns, sheets, full screen covers, and any presented alert, confirmation
dialog, or error:

```swift
print(navigator.debugDescription)
```

For an interactive, always-on-top version of the same view, see
[Debugging](Debugging.md).
