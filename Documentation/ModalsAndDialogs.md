# Modals & Dialogs

## One vocabulary

```swift
navigator.present(route)                                   // route's `presentation` trait, else .sheet
navigator.present(route, as: .sheet)
navigator.present(route, as: .sheet(detents: [.medium, .large]))
navigator.present(route, as: .cover)                       // full-screen cover on iOS, sheet on macOS
navigator.present(route, as: .cover(zoomFrom: "photo-42")) // zoom transition from a source view
navigator.present(route, as: .popover)
navigator.present(route, as: .inspector)
navigator.present(route, as: .window)                      // new window where supported, else sheet
navigator.dismiss()
```

Each presented route gets its own stack, so `push` inside a sheet just works, and presenting from a sheet stacks another modal on top. `dismiss()` closes the nearest modal — from any depth of its stack.

### Traits

Let the route decide, keep the call site to `navigator.open(route)`:

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
navigator.present(PhotoRoute.viewer(photo.id), as: .cover(zoomFrom: photo.id))
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

## Results

A presented screen hands a value back with `dismiss(returning:)`. Handle it in a callback:

```swift
navigator.present(ColorRoute.picker, returning: Color.self) { color in
    if let color { theme.accent = color }
}
// in the picker:
navigator.dismiss(returning: selectedColor)
```

or, from async code, await it: `let color = await navigator.present(ColorRoute.picker, returning: Color.self)`.

The result is `nil` if the modal was closed any other way — swiped down, tapped outside, dismissed by a tab switch or deep link. Every presentation resolves exactly once, including modals nested inside a dismissed modal. Flows work the same way: `navigator.flow(Checkout(cart: cart)) { order in … }` — see [Flows, Guards & Auth](FlowsGuardsAndAuth.md).

## Dialogs

Each action carries what happens when it's chosen:

```swift
navigator.confirm("Delete draft?", confirm: "Delete", destructive: true) {
    drafts.delete(draft)
}

navigator.alert("Saved", message: "Your changes are live.") { … }

navigator.retry(error) { Task { await upload() } }

navigator.dialog("Share", style: .confirmation) {
    Dialog.Action("Copy Link") { pasteboard.copy(link) }
    Dialog.Action("Message") { compose(link) }
    Dialog.Action("Cancel", role: .cancel)
} onDismiss: {
    // dismissed without choosing, e.g. tapped outside
}
```

The callback forms start the presentation on the next main-actor turn, so they suit button actions. Every call also has an `async` form that returns the outcome, for code already in a `Task`:

```swift
while true {
    do { try await upload(); break }
    catch { guard await navigator.retry(error) else { break } }
}

let choice = await navigator.dialog("Share", style: .confirmation) {
    Dialog.Action("Copy Link", id: "copy")
    Dialog.Action("Cancel", role: .cancel)
}
```

Inside the builder, write each action with its initializer, as you would a `Button` in a SwiftUI alert. The `.default`, `.cancel` and `.destructive` shortcuts are for array literals (`Dialog(title, actions: [.destructive("Delete"), .cancel()])`): on consecutive builder lines, Swift would chain them into a single call.

`Dialog` and `Dialog.Action` contain no SwiftUI types, so view models in `NavigationKitInterface`-only modules can use them.

Presentation sequencing (dismiss, then present; present, then present on top) waits for real appear/disappear callbacks — there are no sleeps.
