# Modals

Every navigator (`StackNavigator`, `TabsNavigator`, `SplitNavigator`) conforms to
`ModalPresenter`, so sheets, full-screen covers, alerts, and confirmation dialogs are presented
through the same object you use for stack/tab/split navigation — no separate `@State` or
`.sheet(isPresented:)` bindings in your views. Each conformer holds its modal state in a single
composed `ModalBox` (accessible as `navigator.modals`), which is what `ModalPresenter`'s default
implementations read and write.

## Sheets & full screen covers

Presenting a sheet or full screen cover creates a **new child `StackNavigator`** rooted at the
given route — modals are always stack-shaped, regardless of what kind of navigator presented
them. That child navigator gets its own stack, so the modal can push further screens
independently of the presenter.

```swift
navigator.presentSheet(SettingsRoute.root)
navigator.presentFullScreenCover(OnboardingRoute.welcome)
```

Dismiss the modal from inside it, using the child navigator:

```swift
// Inside a screen presented as a sheet, holding `navigator` (the child):
navigator.dismiss()
```

`dismiss()` walks up to `presentedBy` and clears whichever of `modals.sheet` /
`modals.fullScreenCover` matches `self`, so it's safe to call from any depth inside the modal's
own stack. It's declared directly on `StackNavigator` (not the shared `ModalPresenter`
protocol) since only stack navigators are ever the thing being presented.

To tear down every modal in the tree at once (e.g. on logout, or before applying a deep link):

```swift
navigator.dismissAllModals()
```

This clears alerts, confirmation dialogs, errors, sheets, and full-screen covers — recursively,
across all tabs and split columns.

## Alerts

Alerts are described declaratively with `AlertSpec`, not constructed as views:

```swift
navigator.present(alert: AlertSpec(
    title: "Delete session?",
    message: "This can't be undone.",
    buttons: [
        .init("Delete", role: .destructive) { store.delete() },
        .init("Cancel", role: .cancel),
    ]
))
```

`StackContainer`, `TabsContainer`, and `SplitContainer` already attach the `.alert` modifier
bound to `navigator.modals.alert`, so presenting one is all you need to do from a screen.

## Errors

Errors get dedicated handling, including an optional retry action:

```swift
navigator.present(error: error) {
    Task { await reload() }
}
```

If the error conforms to `LocalizedError` and provides a `recoverySuggestion`, that's shown as
the alert message; otherwise `error.localizedDescription` is used. Omit `retry` to fall back to
the system's default dismiss button.

## Confirmation dialogs

`ConfirmationDialogSpec` is a type alias for `AlertSpec` — same shape, rendered as a
bottom-anchored action sheet instead of a centered alert:

```swift
navigator.present(confirmationDialog: ConfirmationDialogSpec(
    title: "Export as…",
    buttons: [
        .init("PDF") { export(.pdf) },
        .init("CSV") { export(.csv) },
        .init("Cancel", role: .cancel),
    ]
))
```

## Nesting

Because a sheet's content is rendered through the same `NavigationContainer` recursion, a
modal's child `StackNavigator` can itself present its own further sheets, each with their own
stack. Modals are always stack-shaped — `modals.sheet` / `modals.fullScreenCover` are typed
`StackNavigator?`, not `RootNavigator?` — so a sheet can't be a tabs or split navigator itself;
it can only push further routes or present nested sheets.
