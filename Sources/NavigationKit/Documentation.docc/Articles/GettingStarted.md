# Getting Started

Build your first navigation hierarchy with ``StackNavigator``, ``RouteBuilder``, and
``NavigationContainer``.

## Define routes

Routes are plain `Hashable` values, typically one enum per feature:

```swift
enum HomeRoute: Hashable {
    case feed
    case profile(id: String)
}
```

## Register views for those routes

```swift
let routeBuilder = RouteBuilder()
routeBuilder.register(HomeRoute.self) { route, navigator in
    switch route {
    case .feed:
        FeedScreen(navigator: navigator)
    case let .profile(id):
        ProfileScreen(userID: id, navigator: navigator)
    }
}
```

## Create a navigator and render it

```swift
struct ContentView: View {
    let navigator = StackNavigator(root: HomeRoute.feed)
    let routeBuilder = routeBuilder

    var body: some View {
        NavigationContainer(navigator: .stack(navigator), routeBuilder: routeBuilder)
    }
}
```

## Navigate

```swift
navigator.push(HomeRoute.profile(id: "123"))
navigator.pop()
navigator.popToRoot()
```

For tabs, split views, modals, deep linking, and state snapshots, see the guides in the
repository's `Documentation/` directory: Stacks, Tabs & Split Views; Modals; Deep Linking;
and State Snapshots & Restoration.
