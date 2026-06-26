import SwiftUI

public enum HomeRouteRegistry {
    public static func register(
        in registry: inout DestinationRegistry,
        openCatalog: @escaping (Navigator) -> Void,
        openAccount: @escaping (Navigator) -> Void
    ) {
        registry.register(HomeRoute.self) { route, navigator in
            switch route {
            case .home:
                HomeView(
                    openCatalog: { openCatalog(navigator) },
                    openAccount: { openAccount(navigator) }
                )
            }
        }
    }
}
