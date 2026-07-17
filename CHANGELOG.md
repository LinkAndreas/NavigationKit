# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this
project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Entries for 1.1.0–1.3.5 were reconstructed from the git history. Most of those releases were
continuous-integration and documentation work rather than library changes; they're recorded here
because each one is a published tag you can pin to.

## [Unreleased]

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

[Unreleased]: https://github.com/LinkAndreas/NavigationKit/compare/v1.3.5...HEAD
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
