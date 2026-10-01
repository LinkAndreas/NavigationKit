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

## Results

A presented screen hands a value back with `dismiss(returning:)`. Handle it in a callback:

```swift
nav.present(ColorRoute.picker, returning: Color.self) { color in
    if let color { theme.accent = color }
}
// in the picker:
nav.dismiss(returning: selectedColor)
```

or, from async code, await it: `let color = await nav.present(ColorRoute.picker, returning: Color.self)`.

The result is `nil` if the modal was closed any other way — swiped down, tapped outside, dismissed by a tab switch or deep link. Every presentation resolves exactly once, including modals nested inside a dismissed modal. Flows work the same way: `nav.flow(CheckoutRoute.cart, returning: Order.self) { order in … }`.

## Dialogs

Each action carries what happens when it's chosen:

```swift
nav.confirm("Delete draft?", confirm: "Delete", destructive: true) {
    drafts.delete(draft)
}

nav.alert("Saved", message: "Your changes are live.") { … }

nav.retry(error) { Task { await upload() } }

nav.dialog("Share", style: .confirmation) {
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
    catch { guard await nav.retry(error) else { break } }
}

let choice = await nav.dialog("Share", style: .confirmation) {
    Dialog.Action("Copy Link", id: "copy")
    Dialog.Action("Cancel", role: .cancel)
}
```

Inside the builder, write each action with its initializer, as you would a `Button` in a SwiftUI alert. The `.default`, `.cancel` and `.destructive` shortcuts are for array literals (`Dialog(title, actions: [.destructive("Delete"), .cancel()])`): on consecutive builder lines, Swift would chain them into a single call.

`Dialog` and `Dialog.Action` contain no SwiftUI types, so view models in `NavigationKitInterface`-only modules can use them.

Presentation sequencing (dismiss, then present; present, then present on top) waits for real appear/disappear callbacks — there are no sleeps.
