# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this
project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
