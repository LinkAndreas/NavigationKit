import Foundation

@MainActor
func makeRegistry() -> DestinationRegistry {
    var registry = DestinationRegistry()
    
    CatalogRouteRegistry.register(in: &registry)
    AccountRouteRegistry.register(in: &registry)
    HomeRouteRegistry.register(
        in: &registry,
        openCatalog: { navigator in
            navigator.push(CatalogRoute.list)
        },          // pushed onto home
        openAccount: { navigator in
            navigator.present(sheet: AccountRoute.profile)
        } // presented as sheet
    )

    return registry
}
