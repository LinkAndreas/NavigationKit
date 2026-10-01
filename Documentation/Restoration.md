# Restoration & Handoff

## Restoration

```swift
NavigationRoot { … }.restoration(.sceneStorage("nav"))
// or .userDefaults("nav"), or .custom(load: { … }, save: { … })
```

The store's `snapshot` (`NavigationSnapshot`, `Codable`) is saved whenever navigation changes and restored once when the root appears. Restoration runs in a `.task`, so the very first frame shows the roots before the saved location appears.

### What is restored

- The selected section, and each section's pushed routes. Section *roots* come from code: a saved path is only restored onto a matching root.
- Detail columns, including their root.
- The modal chain of the selected section, re-presented one after another.

### Surviving app updates

Decoding is lossy by design. A route that no longer decodes — a removed case, a renamed type — truncates its stack at that point; a section that can't be decoded is skipped. A broken restore never takes down the whole state.

Route types are registered for decoding automatically when first used. Types that might be restored before they appear (deep in a stack) should be listed in a module's `routeTypes`, or registered with `RouteTypes.register(MyRoute.self)` at launch. Override `routeKey` to keep data compatible across a type rename.

## Handoff

```swift
NavigationRoot { … }.handoff(activityType: "com.example.app.browsing")
```

The current snapshot is published as an `NSUserActivity` and restored when the activity is continued on another device. Declare the activity type in `NSUserActivityTypes` in your Info.plist.

## Manual use

```swift
let data = try JSONEncoder().encode(store.snapshot)
await store.restore(try JSONDecoder().decode(NavigationSnapshot.self, from: data))
```
