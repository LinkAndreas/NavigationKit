# Debugging

`NavigationKitDebug` is an optional module that overlays a draggable floating button on top of
your running app. Tapping it presents the live navigation graph — stacks, tabs, split columns,
sheets, full screen covers, and any active alert / confirmation dialog / error — as plain
monospaced text, generated from the root `RootNavigator`'s `debugDescription`.

It's intended for DEBUG builds only; don't link it into release targets.

## Setup

Add the `NavigationKitDebug` product to your app target, then attach the modifier to your root
view, passing the same `RootNavigator` you render with `NavigationContainer`:

```swift
import NavigationKitDebug

NavigationContainer(navigator: appNavigator, routeBuilder: routeBuilder)
    .withNavigationGraphDebuggerWindow(navigator: appNavigator)
```

This adds a floating, system-level window (above your app's normal view hierarchy) hosting a
red ladybug button. Drag it anywhere on screen; tap it to present the graph in a sheet.

## Gating it to DEBUG builds

The example app wraps the modifier so it's a no-op in release builds — see
[`View+debugger.swift`](../Examples/ShowCaseApp/View+debugger.swift):

```swift
extension View {
    @ViewBuilder
    func withOptionalNavigationGraphDebugger(navigator: RootNavigator) -> some View {
        #if DEBUG
        self.withNavigationGraphDebuggerWindow(navigator: navigator)
        #else
        self
        #endif
    }
}
```

## Reading the output

The graph mirrors the live object tree exactly:

```
📑 Tabs
  Selection: discover
  🟢 Tab: Discover
    🗂 Stack
      Root: DiscoverRoute.discover
  ⚪️ Tab: Schedule
    🗂 Stack
      Root: ScheduleRoute.list
      Path:
        1. ScheduleRoute.session(id: "42")
📄 Sheet
  🗂 Stack
    Root: SettingsRoute.root
```

A split navigator (as used on iPad in `Examples/ShowCaseApp`) prints its sidebar, optional
content, and detail columns the same way:

```
◫ Split (automatic)
  Sidebar:
    🗂 Stack
      Root: AppSidebarRoute.menu
  Detail:
    🗂 Stack
      Root: ScheduleRoute.list
      Path:
        1. ScheduleRoute.session(id: "42")
```

- `🗂 Stack` / `📑 Tabs` / `◫ Split` mark the kind of each navigator.
- `🟢` / `⚪️` mark the selected vs. unselected tab.
- `📄 Sheet` and `🖥 Full Screen Cover` nest the presented navigator's own graph underneath them.
- `⚠️ Alert`, `📝 Confirmation Dialog`, and `❌ Error` appear when those are currently presented.

This is the same string you get by calling `.debugDescription` directly on any navigator or
`RootNavigator` (e.g. to log state transitions in tests), without needing the floating window
at all.
