# Modals & Dialogs

## One vocabulary

```swift
nav.present(route)                                   // route's `presentation` trait, else .sheet
nav.present(route, as: .sheet)
nav.present(route, as: .sheet(detents: [.medium, .large]))
nav.present(route, as: .cover)                       // full-screen cover on iOS, sheet on macOS
nav.present(route, as: .cover(zoomFrom: "photo-42")) // zoom transition from a source view
nav.present(route, as: .popover)
nav.present(route, as: .inspector)
nav.present(route, as: .window)                      // new window where supported, else sheet
nav.dismiss()
```

Each presented route gets its own stack, so `push` inside a sheet just works, and presenting from a sheet stacks another modal on top. `dismiss()` closes the nearest modal — from any depth of its stack.

### Traits

Let the route decide, keep the call site to `nav.open(route)`:

```swift
var presentation: PresentationStyle? {
    switch self {
    case .compose: .sheet(detents: [.medium, .large])
    case .player: .cover
    default: nil            // push
    }
}
```

### Zoom transitions

Mark the source and present with its id:

```swift
PhotoThumbnail(photo).navigationZoomSource(photo.id)
// …
nav.present(PhotoRoute.viewer(photo.id), as: .cover(zoomFrom: photo.id))
```

### Windows

`.window` needs a scene that can open routes. Add it next to your main window and give it the same modules:

```swift
@main struct MyApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
        RouteWindows(ScheduleModule(), SpeakersModule())
    }
}
```

On iPhone (or anywhere multiple windows aren't supported) `.window` falls back to a sheet.

## Awaiting results

```swift
let color = await nav.present(ColorRoute.picker, returning: Color.self)
// in the picker:
nav.dismiss(returning: selectedColor)
```

The result is `nil` if the modal was closed any other way — swiped down, tapped outside, dismissed by a tab switch or deep link. Every pending await is resolved exactly once, including for modals nested inside a dismissed modal.

## Dialogs

Dialogs are data you await, not state you wire:

```swift
if await nav.confirm("Delete draft?", confirm: "Delete", destructive: true) {
    drafts.delete(draft)
}

await nav.alert("Saved", message: "Your changes are live.")

while true {
    do { try await upload(); break }
    catch { guard await nav.retry(error) else { break } }
}

let choice = await nav.dialog("Share", style: .confirmation) {
    .default("Copy Link", id: "copy")
    .default("Message", id: "message")
    .cancel()
}
```

`Dialog` and `Dialog.Action` contain no SwiftUI types, so view models in `NavigationKitInterface`-only modules can use them. Actions may also carry a handler for callers that prefer not to await.

Presentation sequencing (dismiss, then present; present, then present on top) waits for real appear/disappear callbacks — there are no sleeps.
