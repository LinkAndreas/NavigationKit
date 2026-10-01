# Debugging

## Events

Every change in the tree is a `NavigationEvent`:

```swift
NavigationRoot { … }
    .onNavigationEvent { event in
        if case let .pushed(route) = event { analytics.track(screen: route.description) }
    }
```

Or consume them as a stream, e.g. from an app-level service:

```swift
for await event in store.events() { logger.debug("\(event)") }
```

Events include pushes and pops, presentations and dismissals, section changes, flow completion, dialogs, deep links (opened and failed), auth prompts, guard blocks, ignored duplicate pushes, unhandled actions, and restoration. Unhandled actions are also printed in DEBUG builds.

## The debugger overlay

```swift
import NavigationKitDebug

NavigationRoot { … }
    .navigationDebugger()     // no-op in release builds
```

A floating button opens a sheet with the current location as steps, the full tree (every section, stack and modal), and the recent events.
