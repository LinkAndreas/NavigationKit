import SwiftUI

@main struct MyApp: App {
    @State private var navigator = Navigator(root: HomeRoute.home)
    private let registry = makeRegistry()
    private let resolver = makeResolver()

    var body: some Scene {
        WindowGroup {
            WithNavigationContext(navigator, registry: registry)
                .onOpenURL { url in
                    if let state = resolver.resolve(url) { navigator.apply(state) }
                }
        }
    }
}
