# Deep Linking

## Steps

A deep link resolves to a list of `Step`s — a path that doesn't depend on the layout:

```swift
[.select(AppTab.schedule), .show(ScheduleRoute.session(id: "42"))]
```

| Step | Meaning |
|---|---|
| `.select(id)` | Select a section and reset it to its root |
| `.push(route)` | Push onto the current stack |
| `.show(route)` | Detail column in a split layout, push otherwise |
| `.present(route, as: style)` | Present; later steps apply inside the modal |

The same steps drive `nav.navigate(_:)`, restoration and test assertions (`store.currentSteps`).

## Handling URLs

```swift
enum AppLinks: DeepLinks {
    static func steps(for url: URL) -> [Step]? {
        let segments = url.segments                 // myapp://schedule/session/42 → ["schedule", "session", "42"]
        switch segments.first {
        case "schedule":
            guard segments.count == 3 else { return [.select(AppTab.schedule)] }
            return [.select(AppTab.schedule), .show(ScheduleRoute.session(id: segments[2]))]
        case "account":
            return [.select(AppTab.discover), .present(AccountRoute.profile), .push(AccountRoute.settings)]
        default:
            return nil
        }
    }
}

NavigationRoot { … }.deepLinks(AppLinks.self)       // or .deepLinks { url in … }
```

`NavigationRoot` installs `onOpenURL`. Screens can open links too: `nav.open(url)` returns `false` if nothing matched. Unmatched links emit `.deepLinkFailed`.

A good split: each feature parses its own segments into root-relative routes; the app decides where they're mounted.

## What happens on navigate

1. Guards of everything being discarded are asked (modals, and the selected section's pushed screens).
2. All modals are dismissed — and the store waits until they're actually gone.
3. The selected section resets to its root, then steps apply in order. Each `.present` waits until the modal is on screen before the next step.
