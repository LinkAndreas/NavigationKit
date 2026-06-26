import SwiftUI

@MainActor
public struct WithNavigationContext: View {
    @Bindable private var navigator: Navigator
    private let registry: DestinationRegistry
    public init(_ navigator: Navigator, registry: DestinationRegistry) {
        self._navigator = Bindable(navigator); self.registry = registry
    }
    public var body: some View {
        NavigationStack(path: $navigator.path) {
            registry.view(for: navigator.root, navigator: navigator)
                .navigationDestination(for: AnyRoute.self) { route in
                    registry.view(for: route, navigator: navigator)
                }
        }
        .sheet(item: $navigator.sheet) { child in
            WithNavigationContext(child, registry: registry)
        }
        .fullScreenCover(item: $navigator.fullScreenCover) { child in
            WithNavigationContext(child, registry: registry)
        }
    }
}
