import Foundation

@MainActor
func makeResolver() -> DeepLinkResolver {
    var r = DeepLinkResolver()

    // /catalog/...  → mounted as a pushed stack on the Home root.
    r.register { url in
        guard let routes = CatalogDeepLink.parse(url.segments) else { return nil }
        return NavigationState(root: HomeRoute.home).pushing(all: routes)
    }

    // /account/... → mounted as a SHEET over Home, with its own internal stack.
    r.register { url in
        guard let routes = AccountDeepLink.parse(url.segments), let head = routes.first
        else { return nil }
        let sheet = NavigationState(root: head).pushing(all: Array(routes.dropFirst()))
        return NavigationState(root: HomeRoute.home).presentingSheet(sheet)
    }

    return r
}
