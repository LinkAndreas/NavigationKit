---
name: Bug report
about: Report something that isn't working as expected
title: ""
labels: bug
assignees: ""
---

## Description

A clear description of what's wrong.

## Reproduction

A minimal setup that reproduces the issue — ideally a headless `NavigationStore`, e.g.:

```swift
let store = NavigationStore(root: SomeRoute.root)
store.navigator.push(SomeRoute.detail)
// ...
print(store.currentSteps)
```

## Expected behavior

What you expected to happen.

## Actual behavior

What happened instead. Include `store.currentSteps` and `store.recentEvents` if relevant.

## Environment

- NavigationKit version (or commit SHA):
- Xcode version:
- Swift version:
- iOS version / Simulator:
