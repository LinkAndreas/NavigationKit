# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this
project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Entries for 1.1.0–1.3.5 were reconstructed from the git history. Most of those releases were
continuous-integration and documentation work rather than library changes; they're recorded here
because each one is a published tag you can pin to.

## [Unreleased]

## [3.1.1] - 2026-10-02

### Fixed

- `remember(for:)` created a throwaway value when a screen rendered again after leaving its stack —
  while animating out after a pop, a finished flow, or a replaced detail column — so `init`/`deinit`
  ran more than once per lifetime. A leaving screen now keeps its values until its view is gone.

## [3.1.0] - 2026-10-02

### Added

- `Navigator.remember(for:_:)`: keeps a value for a lifetime — `.screen`, `.flow`,
  `.flow(SomeFlow.self)` or `.window`. It's created the first time it's asked for, every later call
  returns the same value, and it's released when the lifetime ends (the screen leaves its stack, the
  flow run finishes, is cancelled or backed out of, or the `NavigationRoot` goes away). Features can
  scope their dependencies to exactly where they're used, and pass them to screens by initializer.
- `RecordingNavigator` remembers too, and `end(_:)` releases a lifetime in tests.
- The ShowCase app's proof flow collects its result in a draft remembered for the flow.

## [3.0.0] - 2026-10-02

### Added

- `Flow`: a reusable, multi-step process declared as a plain `Route` with a `start` step and a typed
  `Result`. Start it as one unit with `nav.flow(Checkout())` (`async`, returning `Result?`) or
  `nav.flow(Checkout()) { result in … }`. A step can run another flow and continue with its result,
  so feature teams can publish flows that others compose. On screen, a flow is its start step, and
  it takes its `presentation`, `requiresAuth` and `hidesTabBar` traits from it.
- `cancelFlow()`: ends the innermost flow, unwinding its screens; the caller sees it as abandoned.
- The ShowCase app's hackathon registration is a `Flow` that runs a reusable `ProofFlow`.

### Changed

- **Breaking:** every screen comes from a module. Routes no longer render themselves; move each
  `ViewRoute.body(_:)` into a `TypedRouteModule` and list it with `.routes(…)`. See
  [Migration](Documentation/Migration.md).
- **Breaking:** the route-based `flow(_:as:)` and `flow(_:as:onFinish:)` are disfavored overloads, so
  a `Flow` always resolves to its typed form.
- `.routes(…)` documents that repeated calls add up.

### Removed

- **Breaking:** `ViewRoute` and `ViewRoute.preview()`. Use `route.preview(using: SomeModule())`.

## [2.4.0] - 2026-10-01

### Added

- Callback forms of the awaited calls, for button actions that shouldn't need a `Task`:
  `present(_:as:returning:onDismiss:)`, `flow(_:as:returning:onFinish:)`, `flow(_:as:onFinish:)`,
  `dialog(_:message:style:actions:onDismiss:)` (the chosen action's handler runs),
  `confirm(…onConfirm:)`, `alert(…onDismiss:)` and `retry(_:title:onRetry:)`. The `async` forms remain.

## [2.3.0] - 2026-10-01

### Added

- `TypedRouteModule`: a module for one route type whose screens are an exhaustive `switch`, so a new
  case without a screen is a compile error. `register(in:)` and `routeTypes` are provided.
- `RouteRegistry.missingViews(for:)`: lists route types that are neither registered nor `ViewRoute`s,
  for a test that fails when a module is missing from `.routes(…)`.

## [2.2.0] - 2026-10-01

### Changed

- `RootSection`'s `root:` and `detail:` closures return `any Route`, so sections can be built from
  data whose tabs use different route types. Closures returning a concrete route keep working.

## [2.1.2] - 2026-10-01

### Changed

- The README has a cheat sheet covering routes, the root, navigating, modals, dialogs, flows, guards,
  deep links, restoration and testing.

## [2.1.1] - 2026-10-01

### Fixed

- The navigation debugger sheet collapsed to its toolbar on macOS; it now opens at a usable size.

## [2.1.0] - 2026-10-01

### Added

- Custom sidebars: `NavigationRoot(selection:sections:sidebar:)` and
  `NavigationRoot(store:selection:sidebar:)` take your own sidebar view, which receives the selected
  section as a binding, like `NavigationSplitView`'s sidebar.

## [2.0.1] - 2026-10-01

### Fixed

- A screen inside a sheet or cover can disable swipe-to-dismiss with `interactiveDismissDisabled()`
  again. An `.inspector` presented from inside a modal is shown as a sheet.

## [2.0.0] - 2026-10-01

A redesign around one layout-agnostic `Navigator` and a declarative `NavigationRoot`. See
[Migrating to 2.0](Documentation/Migration.md).

### Added

- `NavigationKitInterface`: `Route`, `Navigator`, `RouteNavigator`, `Step`, `Dialog`,
  `PresentationStyle`, `NavigationAction` and `NavigationEvent`, with no SwiftUI dependency.
- `NavigationRoot` with `RootSection`s and `.layout(.stack | .tabs | .split | .adaptive)`; the sidebar
  is built in, and sections with a `detail:` get a three-column split view.
- Scoped navigators: actions bubble to the nearest container that can handle them.
  `show(_:)` targets the detail column in split layouts and pushes otherwise.
- One presentation API: `present(_:as:)` with `.sheet`, `.sheet(detents:)`, `.cover`,
  `.cover(zoomFrom:)`, `.popover`, `.inspector` and `.window` (plus the `RouteWindows` scene).
- Route traits: `presentation`, `requiresAuth`, `hidesTabBar`; `open(_:)` honors them.
- `ViewRoute`: routes that render themselves. `RouteModule` and `RouteRegistry` for routes that can't.
- Awaited results: `present(_:as:returning:)`, `dismiss(returning:)`, `confirm`, `alert`, `retry`, `dialog`.
  Dialog texts are `LocalizedStringResource`s, and dialog builders list `Dialog.Action`s by initializer.
- Flows: `flow(_:as:returning:)` and `finishFlow(returning:)`, unwinding exactly the flow's screens.
- `navigationGuard(when:…)` for unsaved changes, enforced for back, dismiss, tab switches and deep links.
- `authGate(isAuthenticated:login:)`.
- Layout-independent paths: `navigate(_:)` with an array of steps, `DeepLinks`, `NavigationStore.currentSteps`.
- `NavigationSnapshot` (`Codable`, versioned, lossy decoding), `.restoration(_:)`, `.handoff(activityType:)`.
- `NavigationEvent` stream: `onNavigationEvent(_:)`, `NavigationStore.events()`.
- `NavigationKitTesting` with `RecordingNavigator`; `NavigationStore` works headless.
- `RouteLink`, `navigationZoomSource(_:)`, and `ViewRoute.preview()` / `Route.preview(using:)`.
- Duplicate-push protection.

### Changed

- **Breaking:** routes conform to `Route` (`Hashable`, `Codable`, `Sendable`) instead of `Hashable`.
- **Breaking:** `NavigationKitDebug` is now an overlay with a draggable button
  (`NavigationRoot.navigationDebugger()`) instead of a separate debugger window.
- Nested presentations are sequenced on appear/disappear callbacks instead of a fixed delay, and
  presentations at launch (restoration, deep links) wait until the scene is active.

### Removed

- **Breaking:** `StackNavigator`, `TabsNavigator`, `SplitNavigator`, `AdaptiveNavigator`, `RootNavigator`,
  `NavigationContainer`, `RouteBuilder`, `ModalPresenter`, `AlertSpec`, `StackState`, `TabsState`,
  `SplitState`, `SplitVisibility`, `SidebarColumnWidth`, `NavigationState`, `DeeplinkResolver` and
  `applyDeepLink`. Split-view column widths and visibility are not configurable in 2.0.0 yet.

## [1.5.0] - 2026-09-23

### Added

- `AdaptiveNavigator` and `RootNavigator.adaptive`: a tab bar in a narrow window and a split view
  in a wide one, switching whenever the window's horizontal size class changes — unfolding a
  foldable iPhone, resizing an iPad app in Split View or Stage Manager, or rotating a large iPhone.
  Its own sheet, full-screen cover, and alerts sit above both layouts, so they stay up through a
  switch; `onLayoutChange` lets the app carry its selection across. A `switch` over
  `RootNavigator` needs a case for it.

## [1.4.0] - 2026-07-29

### Added

- `SplitNavigator.sidebarColumnWidth`: an optional `SidebarColumnWidth` (minimum, ideal, maximum)
  forwarded to the sidebar column's `navigationSplitViewColumnWidth`.

## [1.3.6] - 2026-07-17

### Added

- macOS 26 support. The core library needed no changes beyond full-screen covers: the navigators,
  routing, state snapshots, and deep linking were already free of UIKit.
- macOS support in `NavigationKitDebug`. The floating ladybug button gets its own button-sized
  `NSPanel`, attached to the app's window so it follows the window and stays above any sheet the
  app presents. Dragging moves the button; clicking it opens the navigation graph in a separate
  window, the macOS idiom for an inspector.
- CI runs the test suite on macOS as well as iOS, so macOS support can't silently regress the way
  it did in 1.1.5.

### Changed

- `present(fullScreenCover:)` presents a sheet on macOS, which has no full-screen cover. The API
  and `StackState.Modal.fullScreenCover` are identical on both platforms, so navigation state and
  deep links still round-trip across them.

## [1.3.5] - 2026-07-03

### Fixed

- Screenshot table widths in the README.

## [1.3.4] - 2026-07-03

### Changed

- Lay out the README screenshot galleries with HTML tables.

## [1.3.3] - 2026-07-03

### Fixed

- ShowCase App section title and screenshot width in the README.

## [1.3.2] - 2026-07-03

### Fixed

- README formatting.

## [1.3.1] - 2026-07-02

### Changed

- README screenshot sizing.

## [1.3.0] - 2026-07-02

### Added

- ShowCase App screenshots (iPhone and iPad, light and dark) in the README.

### Removed

- German default localization from the ShowCase App.

## [1.2.2] - 2026-07-02

### Changed

- Update the GitHub Actions used by CI.

## [1.2.1] - 2026-07-02

### Fixed

- Pin CI to Node.js 24 instead of 20.

## [1.2.0] - 2026-07-02

### Added

- Localization for the ShowCase App.

### Changed

- Expand the DocC and guide documentation across the navigators, modals, routing, and state
  snapshot types.

## [1.1.13] - 2026-07-02

### Fixed

- DocC routing for the GitHub Pages documentation site.

## [1.1.12] - 2026-07-02

### Added

- Allow the CI workflow to be run manually.

## [1.1.11] - 2026-07-02

### Changed

- README updates.

## [1.1.10] - 2026-07-02

### Added

- Publish generated DocC documentation from CI.

## [1.1.9] - 2026-07-02

### Fixed

- Skip code signing when building the ShowCase App in CI.

## [1.1.8] - 2026-07-02

### Fixed

- Specify the iOS platform when building the ShowCase App in CI.

## [1.1.7] - 2026-07-02

### Changed

- Use `actions/checkout@v5` and adjust the CI test destination.

## [1.1.6] - 2026-07-02

### Changed

- Present alerts and error alerts through the `isPresented:presenting:` modifiers on all supported
  versions, dropping the iOS 27-only `item:` branch that sat behind `#available`.

## [1.1.5] - 2026-07-02

### Removed

- The declared macOS 26 platform, along with the `macOS 27.0` availability annotations added in
  1.1.1. CI moved from `swift test` — which builds for the host, and therefore for macOS — to an
  iOS Simulator `xcodebuild` destination, leaving the package iOS-only. macOS support returns in
  the Unreleased section above.

## [1.1.4] - 2026-07-02

### Changed

- Simplify the CI build pipeline and drop the unused `Navigator.xcworkspace`.

## [1.1.3] - 2026-07-02

### Changed

- Build the ShowCase App in the Swift 6 language mode.

## [1.1.2] - 2026-07-02

### Changed

- Move the package manifests to `swift-tools-version` 6.3.2.

## [1.1.1] - 2026-07-02

### Added

- Declared macOS 26 as a supported platform, with `macOS 27.0` availability annotations alongside
  the existing iOS ones. Removed again in 1.1.5.

### Changed

- Lower the iOS deployment target from 27 to 26.
- Update the architectural diagrams and logo in the README.

## [1.1.0] - 2026-07-02

### Changed

- README updates.

## [1.0.0] - 2026-07-01

### Added

- Initial public release of `NavigationKit`: three `@Observable` navigator classes —
  `StackNavigator` (push/pop), `TabsNavigator` (multi-root tabs), and `SplitNavigator`
  (sidebar/content/detail `NavigationSplitView`) — each owning only the state its shape needs.
  `RootNavigator` is a thin enum over the three, used wherever a caller needs to hold or render
  "a navigator" without committing to a shape up front (`NavigationContainer`, `applyDeepLink`);
  the compiler enforces exhaustiveness on it instead of a runtime `kind` flag.
- `ModalPresenter`: sheet/full-screen-cover/alert/confirmation-dialog presentation shared by all
  three navigator types via a single composed `ModalBox`, so modal state and dismiss-everywhere
  logic aren't duplicated per type.
- Type-erased `Hashable` routes via `AnyRoute`, a `RouteBuilder` view registry, `DeeplinkResolver`
  for URL-based deep linking, and `StackState`/`TabsState`/`SplitState` snapshots (plus
  `SplitVisibility`) for restoring navigation trees, including presented modals.
- `NavigationKitDebug`: a floating, draggable debugger window that visualizes the live
  navigation graph.
- `Examples/ShowCaseApp`: a multi-module example app demonstrating tabs, nested stacks, modals,
  and deep links across several feature packages. The root navigator adapts to the device:
  a tab bar on iPhone, a sidebar + detail split view on iPad.

[Unreleased]: https://github.com/LinkAndreas/NavigationKit/compare/v3.1.1...HEAD
[3.1.1]: https://github.com/LinkAndreas/NavigationKit/compare/v3.1.0...v3.1.1
[3.1.0]: https://github.com/LinkAndreas/NavigationKit/compare/v3.0.0...v3.1.0
[3.0.0]: https://github.com/LinkAndreas/NavigationKit/compare/v2.4.0...v3.0.0
[2.4.0]: https://github.com/LinkAndreas/NavigationKit/compare/v2.3.0...v2.4.0
[2.3.0]: https://github.com/LinkAndreas/NavigationKit/compare/v2.2.0...v2.3.0
[2.2.0]: https://github.com/LinkAndreas/NavigationKit/compare/v2.1.2...v2.2.0
[2.1.2]: https://github.com/LinkAndreas/NavigationKit/compare/v2.1.1...v2.1.2
[2.1.1]: https://github.com/LinkAndreas/NavigationKit/compare/v2.1.0...v2.1.1
[2.1.0]: https://github.com/LinkAndreas/NavigationKit/compare/v2.0.1...v2.1.0
[2.0.1]: https://github.com/LinkAndreas/NavigationKit/compare/v2.0.0...v2.0.1
[2.0.0]: https://github.com/LinkAndreas/NavigationKit/compare/v1.5.0...v2.0.0
[1.5.0]: https://github.com/LinkAndreas/NavigationKit/compare/v1.4.0...v1.5.0
[1.4.0]: https://github.com/LinkAndreas/NavigationKit/compare/v1.3.6...v1.4.0
[1.3.6]: https://github.com/LinkAndreas/NavigationKit/compare/v1.3.5...v1.3.6
[1.3.5]: https://github.com/LinkAndreas/NavigationKit/compare/v1.3.4...v1.3.5
[1.3.4]: https://github.com/LinkAndreas/NavigationKit/compare/v1.3.3...v1.3.4
[1.3.3]: https://github.com/LinkAndreas/NavigationKit/compare/v1.3.2...v1.3.3
[1.3.2]: https://github.com/LinkAndreas/NavigationKit/compare/v1.3.1...v1.3.2
[1.3.1]: https://github.com/LinkAndreas/NavigationKit/compare/v1.3.0...v1.3.1
[1.3.0]: https://github.com/LinkAndreas/NavigationKit/compare/v1.2.2...v1.3.0
[1.2.2]: https://github.com/LinkAndreas/NavigationKit/compare/v1.2.1...v1.2.2
[1.2.1]: https://github.com/LinkAndreas/NavigationKit/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/LinkAndreas/NavigationKit/compare/v1.1.13...v1.2.0
[1.1.13]: https://github.com/LinkAndreas/NavigationKit/compare/v1.1.12...v1.1.13
[1.1.12]: https://github.com/LinkAndreas/NavigationKit/compare/v1.1.11...v1.1.12
[1.1.11]: https://github.com/LinkAndreas/NavigationKit/compare/v1.1.10...v1.1.11
[1.1.10]: https://github.com/LinkAndreas/NavigationKit/compare/v1.1.9...v1.1.10
[1.1.9]: https://github.com/LinkAndreas/NavigationKit/compare/v1.1.8...v1.1.9
[1.1.8]: https://github.com/LinkAndreas/NavigationKit/compare/v1.1.7...v1.1.8
[1.1.7]: https://github.com/LinkAndreas/NavigationKit/compare/v1.1.6...v1.1.7
[1.1.6]: https://github.com/LinkAndreas/NavigationKit/compare/v1.1.5...v1.1.6
[1.1.5]: https://github.com/LinkAndreas/NavigationKit/compare/v1.1.4...v1.1.5
[1.1.4]: https://github.com/LinkAndreas/NavigationKit/compare/v1.1.3...v1.1.4
[1.1.3]: https://github.com/LinkAndreas/NavigationKit/compare/v1.1.2...v1.1.3
[1.1.2]: https://github.com/LinkAndreas/NavigationKit/compare/v1.1.1...v1.1.2
[1.1.1]: https://github.com/LinkAndreas/NavigationKit/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/LinkAndreas/NavigationKit/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/LinkAndreas/NavigationKit/releases/tag/v1.0.0
