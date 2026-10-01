# Getting Started

Define routes, declare a root, navigate.

## Define routes

```swift
enum SpeakersRoute: ViewRoute {
    case overview, detail(id: String)

    func body(_ nav: RouteNavigator<Self>) -> some View {
        switch self {
        case .overview: SpeakerList(onSelect: { nav.push(.detail(id: $0)) })
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
    }
}
```

## Navigate

```swift
nav.push(.detail(id: "s1"))
nav.present(ComposeRoute.new, as: .sheet(detents: [.medium]))
if await nav.confirm("Discard draft?", destructive: true) { nav.dismiss() }
let order = await nav.flow(CheckoutRoute.cart, returning: Order.self)
```

## Next steps

Sections and adaptive layouts, modals, flows, guards, deep links and restoration are covered in the guides in the repository's `Documentation` folder.
