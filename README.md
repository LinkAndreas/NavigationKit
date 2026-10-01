<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="Documentation/NavigationKit-editorial-dark.svg">
    <img src="Documentation/NavigationKit-editorial-light.svg" alt="NavigationKit Logo" width="100%" />
  </picture>

  [![Tests iOS](https://img.shields.io/github/actions/workflow/status/linkandreas/NavigationKit/ci.yml?branch=main&job=Test%20NavigationKit%20%28iOS%29&label=tests%20%28iOS%29)](https://github.com/linkandreas/NavigationKit/actions/workflows/ci.yml)
  [![Tests macOS](https://img.shields.io/github/actions/workflow/status/linkandreas/NavigationKit/ci.yml?branch=main&job=Test%20NavigationKit%20%28macOS%29&label=tests%20%28macOS%29)](https://github.com/linkandreas/NavigationKit/actions/workflows/ci.yml)
  [![ShowCase App](https://img.shields.io/github/actions/workflow/status/linkandreas/NavigationKit/ci.yml?branch=main&job=Build%20ShowCaseApp%20example&label=showcase%20app)](https://github.com/linkandreas/NavigationKit/actions/workflows/ci.yml)
  [![Documentation](https://img.shields.io/github/actions/workflow/status/linkandreas/NavigationKit/ci.yml?branch=main&job=Build%20documentation&label=docs)](https://github.com/linkandreas/NavigationKit/actions/workflows/ci.yml)
  [![Swift 6.4](https://img.shields.io/badge/Swift-6.4-F05138.svg)](https://swift.org)
  [![iOS 26.0+](https://img.shields.io/badge/iOS-26.0%2B-blue.svg)](https://apple.com/ios)
  [![macOS 26.0+](https://img.shields.io/badge/macOS-26.0%2B-blue.svg)](https://apple.com/macos)
  [![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/)
  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

</div>

---

`NavigationKit` models your app's entire navigation hierarchy — stacks, tabs, split views, sheets, full-screen covers, alerts, and confirmation dialogs — as plain, observable, serializable state, so screens never reach for `NavigationLink`, `.sheet`, or `.fullScreenCover` directly.


`NavigationKit` gives every screen one small, layout-agnostic API — `push`, `present`, `show`, `select`, `dismiss` — and builds the right SwiftUI containers around it: a stack, a tab bar, a sidebar with detail, or all of them adaptively. Navigation state is plain `Codable` data, so deep links, state restoration, Handoff and tests all fall out for free.

```swift
NavigationRoot(selection: AppTab.discover) {
    RootSection(AppTab.discover, "Discover", icon: "sparkles") { DiscoverRoute.home }
    RootSection(AppTab.schedule, "Schedule", icon: "calendar") { ScheduleRoute.list } detail: { ScheduleRoute.placeholder }
}
.layout(.adaptive)                       // tabs on iPhone, sidebar + detail on iPad and Mac
.deepLinks(AppLinks.self)
.restoration(.sceneStorage("nav"))
```

```swift
enum ScheduleRoute: ViewRoute {
    case list, placeholder, session(id: String)

    func body(_ nav: RouteNavigator<Self>) -> some View {
        switch self {
        case .list:        SessionList(onSelect: { nav.show(.session(id: $0)) })   // detail column or push
        case .placeholder: ContentUnavailableView("Select a session", systemImage: "calendar")
        case let .session(id): SessionDetail(id: id)
        }
    }
}
```

## 💡 What issues does it solve?

- **Screens don't know their layout.** A navigator is scoped to the screen that receives it; actions travel up the tree to whichever container can handle them. The same feature works in a tab, a sidebar, a sheet or a window.
- **One verb per intent.** `present(route, as: .sheet(detents: [.medium]))` instead of a modifier per presentation type. Routes can declare traits (`presentation`, `requiresAuth`, `hidesTabBar`), so most call sites are just `nav.open(route)`.
- **Results are awaited, not wired.** `let color = await nav.present(.picker, returning: Color.self)`, `if await nav.confirm("Delete?") { … }`, multi-step flows that `finishFlow(returning:)` and unwind exactly their own screens.
- **Layout-independent paths.** Deep links, `navigate(_:)`, restoration and test assertions all use the same `[Step]` language — no branching on tabs vs. split.
- **No SwiftUI in your models.** The `NavigationKitInterface` target has routes, the `Navigator` protocol, steps and dialogs; view models and route-contract packages depend on it alone.
- **No timing hacks.** Nested presentations are sequenced on real appear/disappear signals.

## 🛠 Requirements

- **iOS** 26.0+
- **macOS** 26.0+
- **Swift** 6.4+
- **Xcode** 27+

On macOS, `.cover` presents a sheet (there is no full-screen cover). Routes, navigators,
snapshots, and deep links behave identically on both platforms — see
[Modals & Dialogs](Documentation/ModalsAndDialogs.md).

---

## 🚀 Installation

### Swift Package Manager

Add `NavigationKit` to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/linkandreas/NavigationKit.git", from: "2.0.0")
]
```

Then add the product(s) you need to your target:

```swift
.target(
    name: "MyApp",
    dependencies: [
        .product(name: "NavigationKit", package: "NavigationKit"),
        // Optional: RecordingNavigator for unit tests.
        .product(name: "NavigationKitTesting", package: "NavigationKit"),
        // Optional: a floating debugger overlay for DEBUG builds.
        .product(name: "NavigationKitDebug", package: "NavigationKit"),
    ]
)
```

Or, in Xcode: **File ▸ Add Package Dependencies…** and paste the repository URL.

---

## 📖 Quick Start

### 1. Define routes

A route is a plain value. Conform to `ViewRoute` and it renders itself — no registration step.

```swift
import NavigationKit

enum SpeakersRoute: ViewRoute {
    case overview
    case detail(id: String)
    case contact(email: String)

    var presentation: PresentationStyle? {          // trait: how `open` shows it
        if case .contact = self { .sheet(detents: [.medium, .large]) } else { nil }
    }

    func body(_ nav: RouteNavigator<Self>) -> some View {
        switch self {
        case .overview:
            SpeakerList(onSelect: { nav.push(.detail(id: $0)) })
        case let .detail(id):
            SpeakerDetail(id: id, onContact: { nav.open(.contact(email: $0)) })
        case let .contact(email):
            MailComposer(to: email, onDone: { nav.dismiss() })
        }
    }
}
```

### 2. Declare the root

```swift
struct ContentView: View {
    var body: some View {
        NavigationRoot(SpeakersRoute.overview)          // a single stack…
    }
}
```

…or sections that adapt to the window:

```swift
NavigationRoot(selection: AppTab.speakers) {
    RootSection(AppTab.speakers, "Speakers", icon: "person.2") { SpeakersRoute.overview }
    RootSection(AppTab.account, "Account", icon: "person.crop.circle") { AccountRoute.profile }
}
.layout(.adaptive)
```

### 3. Navigate

```swift
nav.push(.detail(id: "s1"))
nav.present(ProfileRoute.edit, as: .cover(zoomFrom: "avatar"))
nav.show(.detail(id: "s1"))                 // split detail column, or push in compact width
nav.select(AppTab.account)
nav.dismiss(returning: newValue)

let card = await nav.present(PaymentRoute.add, returning: Card.self)
if await nav.confirm("Discard changes?", confirm: "Discard", destructive: true) { nav.pop() }
let order = await nav.flow(CheckoutRoute.cart, returning: Order.self)

nav.navigate([
    .select(AppTab.schedule),
    .push(ScheduleRoute.session(id: "42")),
])
```

### 4. Test without views

```swift
@Test @MainActor func selectingASpeakerPushesDetail() {
    let nav = RecordingNavigator()
    SpeakerListModel(nav: nav).didSelect(id: "s1")
    #expect(nav.actions == [.push(AnyRoute(SpeakersRoute.detail(id: "s1")))])
}
```

---

## 📚 Documentation & Guides

- [Layouts](Documentation/Layouts.md) — single stack, tabs, split, adaptive; `show` and the detail column
- [Modals & Dialogs](Documentation/ModalsAndDialogs.md) — presentation styles, detents, zoom, windows, awaited results, dialogs
- [Flows, Guards & Auth](Documentation/FlowsGuardsAndAuth.md) — multi-step flows, unsaved-changes guards, the auth gate
- [Routes & Modules](Documentation/RoutesAndModules.md) — `ViewRoute`, `RouteModule`, cross-feature navigation, `RouteLink`
- [Deep Linking](Documentation/DeepLinking.md) — `[Step]`, `DeepLinks`, `navigate`
- [Restoration & Handoff](Documentation/Restoration.md) — snapshots, lossy decoding, versioning
- [Testing](Documentation/Testing.md) — `RecordingNavigator`, headless `NavigationStore`
- [Debugging](Documentation/Debugging.md) — the event stream and the debugger overlay
- [Migrating to 2.0](Documentation/Migration.md) — from NavigationKit 1.x or plain `NavigationStack`

The full API reference is published as DocC.

---

## 🧩 ShowCase App

[`ShowCaseApp`](Examples/ShowCaseApp) is a multi-module conference app that exercises the whole framework. Open `ShowCaseApp.xcproject` and run the `ShowCaseApp` scheme. 

### iPhone

<table width="100%">
  <tr>
    <th align="center">Discover</th>
    <th align="center">Schedule</th>
    <th align="center">My Conf</th>
    <th align="center">Speakers</th>
  </tr>
  <tr>
    <td width="25%" align="center">
      <img src="Examples/ShowCaseApp/Screenshots/light/iphone_discover.png" width="100%" alt="Discover">
    </td>
    <td width="25%" align="center">
      <img src="Examples/ShowCaseApp/Screenshots/light/iphone_schedule.png" width="100%" alt="Schedule">
    </td>
    <td width="25%" align="center">
      <img src="Examples/ShowCaseApp/Screenshots/light/iphone_myconf.png" width="100%" alt="My Conf">
    </td>
    <td width="25%" align="center">
      <img src="Examples/ShowCaseApp/Screenshots/light/iphone_speakers.png" width="100%" alt="Speakers">
    </td>
  </tr>
</table>

### iPad

<table width="100%">
  <tr>
    <th align="center">Discover</th>
    <th align="center">Schedule</th>
  </tr>
  <tr>
    <td width="50%" align="center">
      <img src="Examples/ShowCaseApp/Screenshots/light/ipad_discover.png" width="100%" alt="Discover">
    </td>
    <td width="50%" align="center">
      <img src="Examples/ShowCaseApp/Screenshots/light/ipad_schedule.png" width="100%" alt="Schedule">
    </td>
  </tr>
  <tr>
    <th align="center">My Conf</th>
    <th align="center">Speakers</th>
  </tr>
  <tr>
    <td width="50%" align="center">
      <img src="Examples/ShowCaseApp/Screenshots/light/ipad_myconf.png" width="100%" alt="My Conf">
    </td>
    <td width="50%" align="center">
      <img src="Examples/ShowCaseApp/Screenshots/light/ipad_speakers.png" width="100%" alt="Speakers">
    </td>
  </tr>
</table>

Highlights:
- Adaptive root navigator (tab bar on iPhone, sidebar + detail split view on iPad).
- Per-feature Swift packages registering their own routes.
- Modal sheets hosting nested stacks.
- Deep links resolving into a selected tab and path simultaneously.

---

## 🏗 Architecture Overview

```
NavigationRoot ── NavigationStore (@Observable)
                   └─ SectionNode × n            tab / sidebar item
                       ├─ StackNode (main)       root + path + modal? + dialog?
                       │   └─ ModalNode          style + StackNode (recursive)
                       └─ StackNode (detail)?    split-view detail column
```

Every screen receives a navigator bound to its `StackNode`. An action is resolved there or bubbles up: `push`/`pop` stay on the stack, `dismiss` goes to the nearest modal, `show` to the section's detail column, `select`/`navigate`/`open(url)` to the store. The store is the single source of truth; the views are a projection of it.

## 🤝 Modules

| Product | Contents | Depends on |
|---|---|---|
| `NavigationKitInterface` | `Route`, `Navigator`, `RouteNavigator`, `Step`, `Dialog`, `PresentationStyle`, events — **no SwiftUI** | Foundation |
| `NavigationKit` | `NavigationRoot`, `NavigationStore`, `ViewRoute`, `RouteRegistry`, guards, restoration | Interface (re-exported) |
| `NavigationKitTesting` | `RecordingNavigator` | Interface |
| `NavigationKitDebug` | `.navigationDebugger()` overlay | NavigationKit |

## 🧪 Testing

```bash
xcodebuild test -scheme NavigationKit-Package -destination 'platform=iOS Simulator,name=iPhone 17'
```

The suite drives a headless `NavigationStore` — no simulator UI involved — and asserts on `currentSteps`.

## 🤝 Contributing

Contributions are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md) for how to set up the project, run the test suite, and submit changes. Please also read the [Code of Conduct](CODE_OF_CONDUCT.md).

## 📄 License

`NavigationKit` is released under the MIT license. See [LICENSE](LICENSE) for details.
