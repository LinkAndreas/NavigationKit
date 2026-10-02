# Getting Started

Define routes, give them screens, declare a root, navigate.

## Define routes

```swift
enum SpeakersRoute: Route {
    case overview, detail(id: String)
}
```

## Give them screens

```swift
struct SpeakersModule: RouteModule {
    func body(for route: SpeakersRoute, navigator: RouteNavigator<SpeakersRoute>) -> some View {
        switch route {
        case .overview: SpeakerList(onSelect: { navigator.push(.detail(id: $0)) })
        case let .detail(id): SpeakerDetail(id: id)
        }
    }
}
```

## Declare the root

```swift
struct ContentView: View {
    var body: some View {
        NavigationRoot(SpeakersRoute.overview)
            .routes(SpeakersModule())
    }
}
```

## Navigate

```swift
navigator.push(.detail(id: "s1"))
navigator.present(ComposeRoute.new, as: .sheet(detents: [.medium]))
if await navigator.confirm("Discard draft?", destructive: true) { navigator.dismiss() }
let order = await navigator.flow(Checkout())     // a reusable Flow with a typed result
```

## Next steps

Sections and adaptive layouts, modals, flows, guards, deep links and restoration are covered in the guides in the repository's `Documentation` folder.
