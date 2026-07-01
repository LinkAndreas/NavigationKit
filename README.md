# NavigationKit

A data-driven navigation framework for SwiftUI. `NavigationKit` models your app's entire
navigation hierarchy — stacks, tabs, split views, sheets, full-screen covers, alerts, and
confirmation dialogs — as plain, observable, serializable state, so screens never reach for
`NavigationLink`, `.sheet`, or `.fullScreenCover` directly.

```swift
let navigator = StackNavigator(root: HomeRoute())
navigator.push(ProfileRoute(id: "123"))
navigator.presentSheet(SettingsRoute())
```

## Why

Vanilla SwiftUI navigation modifiers couple a view to the navigation action that presents it.
That makes deep linking, state restoration, previews, and testing harder than they need to be.
`NavigationKit` instead gives you:

- **One state machine per shape, not one for everything.** `StackNavigator`, `TabsNavigator`,
  and `SplitNavigator` are separate `@Observable` classes, each owning only the state its shape
  needs — no dead properties, no `kind` flag to check. `RootNavigator` is a thin enum over the
  three, used only where a caller genuinely doesn't know the shape yet. SwiftUI re-renders from
  them automatically — no bindings to wire by hand.
- **Type-erased, `Hashable` routes.** Define routes as plain `Hashable` values per feature;
  `AnyRoute` lets `NavigationKit` store them in a single heterogeneous path.
- **A decoupled view registry.** `RouteBuilder` maps route types to views, so a feature module
  can register its routes without the navigation layer needing to import that feature.
- **Deep linking built in.** `DeeplinkResolver` turns a `URL` into a `NavigationState` snapshot;
  `applyDeepLink` replays it onto a live `RootNavigator`.
- **Snapshot-based state restoration.** `StackState` / `TabsState` / `SplitState` describe a
  navigation tree as data, so you can persist it, restore it, or build it for a deep link
  without touching live views.
- **A built-in debugger.** `NavigationKitDebug` overlays a live, inspectable graph of the
  navigation tree on top of your running app.

## Requirements

- iOS 27.0+
- Swift 6.4+ (Xcode 27+)

## Installation

### Swift Package Manager

Add `NavigationKit` to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/linkandreas/NavigationKit.git", from: "1.0.0")
]
```

Then add the product(s) you need to your target:

```swift
.target(
    name: "MyApp",
    dependencies: [
        .product(name: "NavigationKit", package: "NavigationKit"),
        // Optional: a floating debugger overlay for DEBUG builds.
        .product(name: "NavigationKitDebug", package: "NavigationKit"),
    ]
)
```

Or, in Xcode: **File ▸ Add Package Dependencies…** and paste the repository URL.

## Quick start

### 1. Define routes

Routes are just `Hashable` values — typically an enum per feature.

```swift
enum HomeRoute: Hashable {
    case feed
    case profile(id: String)
}
```

### 2. Register views for those routes

```swift
let routeBuilder = RouteBuilder()
routeBuilder.register(HomeRoute.self) { route, navigator in
    switch route {
    case .feed:
        FeedScreen(navigator: navigator)
    case let .profile(id):
        ProfileScreen(userID: id, navigator: navigator)
    }
}
```

### 3. Create a navigator and render it

```swift
struct ContentView: View {
    let navigator = StackNavigator(root: HomeRoute.feed)
    let routeBuilder = routeBuilder // from step 2

    var body: some View {
        NavigationContainer(navigator: .stack(navigator), routeBuilder: routeBuilder)
    }
}
```

### 4. Navigate from anywhere that holds a `StackNavigator`

```swift
navigator.push(HomeRoute.profile(id: "123"))
navigator.pop()
navigator.popToRoot()
```

`NavigationContainer` takes a `RootNavigator` — `.stack`, `.tabs`, or `.split` — and switches on
it to render a stack-driven `NavigationStack`, a tab-driven `TabView`, or a split-driven
`NavigationSplitView`, recursively, for as many nested levels as your app needs (tabs
containing stacks, split columns containing stacks, sheets containing their own stacks, etc.).

## Guides

- [Stacks, Tabs & Split Views](Documentation/StacksAndTabs.md) — building navigation hierarchies, tab containers, split views, nested navigators.
- [Modals](Documentation/Modals.md) — sheets, full screen covers, alerts, confirmation dialogs, error presentation.
- [Deep Linking](Documentation/DeepLinking.md) — parsing URLs into navigation state with `DeeplinkResolver`.
- [State Snapshots & Restoration](Documentation/StateSnapshots.md) — `StackState`, `TabsState`, `SplitState`, and each navigator's `apply(_:)`.
- [Debugging](Documentation/Debugging.md) — the `NavigationKitDebug` overlay.

Full API reference is available as a DocC catalog — see [Documentation.docc](Sources/NavigationKit/Documentation.docc) below.

## Example app

[`Examples/ShowCaseApp`](Examples/ShowCaseApp) is a multi-module conference app that exercises
the whole framework: an adaptive root navigator, per-feature Swift packages each registering
their own routes, modal sheets that host their own nested stacks, and deep links that select a
tab and push a path in one step. Open `Navigator.xcworkspace` and run the `ShowCaseApp` scheme.

The root navigator's shape adapts to the device: a tab bar on iPhone, a sidebar + detail split
view on iPad — the same four features and routes drive both.

```swift
// Examples/ShowCaseApp/AppContext.swift
if isSplit {
    let split = SplitNavigator(
        sidebar: StackNavigator(root: AppSidebarRoute.menu),
        detail: appTabItems[0].makeNavigator(),
        columnVisibility: .all
    )
    navigator = .split(split)
} else {
    navigator = .tabs(TabsNavigator(
        tabs: appTabItems.map {
            TabsNavigator.Tab(id: $0.id, title: $0.title, systemImage: $0.systemImage, navigator: $0.makeNavigator())
        },
        selection: AppTab.discover
    ))
}
```

## Modules

| Target | Purpose |
| --- | --- |
| `NavigationKit` | Core framework: `StackNavigator`/`TabsNavigator`/`SplitNavigator`, route registry, deep linking, state snapshots, modal presentation. |
| `NavigationKitDebug` | Optional floating overlay window that visualizes the live navigation graph. Intended for DEBUG builds only. |

## Testing

```bash
xcodebuild test \
  -scheme NavigationKit-Package \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## Contributing

Contributions are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md) for how to set up the
project, run the test suite, and submit changes. Please also read the
[Code of Conduct](CODE_OF_CONDUCT.md).

## License

`NavigationKit` is released under the MIT license. See [LICENSE](LICENSE) for details.
