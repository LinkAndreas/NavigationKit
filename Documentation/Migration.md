# Migrating to 2.0

2.0 replaces the navigator classes with one protocol and a declarative root. Features get simpler; the app's composition root shrinks to a few lines.

## Concept map

| 1.x | 2.0 |
|---|---|
| `StackNavigator`, `TabsNavigator`, `SplitNavigator`, `AdaptiveNavigator`, `RootNavigator` | `NavigationRoot` + `.layout(…)`; features receive `any Navigator` / `RouteNavigator<R>` |
| `NavigationContainer(navigator:routeBuilder:)` | `NavigationRoot { RootSection… }` |
| `RouteBuilder.register(Type.self) { route, navigator in }` | `ViewRoute.body(_:)` on the route, or `RouteModule` + `registry.register { (route: R, nav) in }` |
| Routes: `Hashable` | Routes: `Route` (`Hashable`, `Codable`, `Sendable`) with optional traits |
| `present(sheet:)`, `present(fullScreenCover:)` | `present(_:as:)` with `.sheet`, `.sheet(detents:)`, `.cover`, `.popover`, `.inspector`, `.window` |
| `present(alert: AlertSpec(…))` | `await nav.confirm(…)`, `alert`, `retry`, `dialog { … }` |
| `popTo(_:)` | `pop(to:) -> Bool` |
| `SplitNavigator.showDetail(_:)` | `show(_:)` (works in every layout) |
| Selecting tabs via `TabsNavigator` | `select(_:)` (works for tabs and sidebar) |
| `StackState`, `TabsState`, `SplitState`, `NavigationState` | `NavigationSnapshot` (`Codable`), `[Step]` |
| `DeeplinkResolver`, `applyDeepLink` | `DeepLinks` protocol / `.deepLinks { url in [Step] }` |
| Debugger window | `.navigationDebugger()` overlay + `onNavigationEvent` |
| Hand-written sidebar screen | Built in: sections render as a sidebar in split layouts |

## Step by step

1. **Routes**: change `: Hashable` to `: Route`. Nested payload enums need `Codable, Sendable`.
2. **Screens**: move each `RouteBuilder` registration into a `ViewRoute` extension (same switch, `navigator` → `nav`, leading-dot routes). Keep a `RouteModule` only where screens need injected dependencies or cross-feature routes.
3. **Modals**: `present(sheet: x)` → `present(x)` or a `presentation` trait + `open(x)`. Full-screen covers → `.cover`.
4. **Alerts**: replace `AlertSpec` buttons with an awaited `confirm`:
   ```swift
   // 1.x
   navigator.present(alert: AlertSpec(title: "Log out?", buttons: [
       .init("Log out", role: .destructive) { navigator.dismiss() }, .init("Cancel", role: .cancel)]))
   // 2.0
   Task { if await nav.confirm("Log out?", confirm: "Log out", destructive: true) { nav.dismiss() } }
   ```
5. **Wizards**: where a step does `popTo(.dashboard)` to finish, start the wizard with `nav.flow(…)` and finish with `nav.finishFlow()`.
6. **Root**: replace the navigator construction and any `isSplit` branching with `NavigationRoot { RootSection… }.layout(.adaptive)`. Delete your sidebar screen.
7. **Deep links**: return `[Step]` instead of navigator state. Use `.show` for items that belong in a detail column — the same steps work on iPhone and iPad.
8. **Restoration**: `.restoration(.sceneStorage("nav"))`.

The ShowCase app in `Examples/` was migrated this way; its diff is a worked example.

## From plain `NavigationStack`

- `NavigationStack(path:)` + `.navigationDestination(for:)` → `NavigationRoot(rootRoute)` + `ViewRoute`.
- `@State var isPresented` + `.sheet` → `nav.present(route)`; the presented view calls `nav.dismiss()`.
- `@Environment(\.dismiss)` still works inside presented screens; prefer `nav.dismiss(returning:)` when you need to hand back a value.
- Adopt incrementally with `RouteLink` inside existing lists.
