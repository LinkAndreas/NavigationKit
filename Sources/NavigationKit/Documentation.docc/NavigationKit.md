# ``NavigationKit``

A data-driven navigation framework for SwiftUI.

## Overview

`NavigationKit` models an app's navigation hierarchy — stacks, tabs, split views, sheets,
full-screen covers, alerts, and confirmation dialogs — as observable, serializable state,
rather than as imperative view modifiers. Each shape is its own `@Observable` class
(``StackNavigator``, ``TabsNavigator``, ``SplitNavigator``, and ``AdaptiveNavigator``, which
switches between a tab bar and a split view as its window's width changes); ``RootNavigator`` is
a thin enum over them, used wherever a caller needs to hold or render "a navigator" without
committing to a shape up front. The same state can be captured as a snapshot (``StackState``,
``TabsState``, ``SplitState``) for deep linking and restoration.

```swift
let navigator = StackNavigator(root: HomeRoute.feed)
navigator.push(HomeRoute.profile(id: "123"))
navigator.presentSheet(SettingsRoute.root)
```

## Topics

### Essentials

- ``RootNavigator``
- ``StackNavigator``
- ``TabsNavigator``
- ``SplitNavigator``
- ``AdaptiveNavigator``
- ``AdaptiveLayout``
- ``NavigationContainer``
- ``RouteBuilder``
- ``AnyRoute``

### Modals

- ``ModalPresenter``
- ``ModalBox``
- ``AlertSpec``
- ``ConfirmationDialogSpec``

### Deep Linking

- ``DeeplinkResolver``
- ``applyDeepLink(_:to:)``

### State Snapshots

- ``NavigationState``
- ``StackState``
- ``TabsState``
- ``SplitState``
- ``SplitVisibility``

### Articles

- <doc:GettingStarted>
