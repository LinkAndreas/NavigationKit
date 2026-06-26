import SwiftUI

public enum CatalogRouteRegistry {
    public static func register(in registry: inout DestinationRegistry) {
        registry.register(CatalogRoute.self) { route, nav in
            switch route {
            case .list:
                List(1...20, id: \.self) { id in
                    Button("Product #\(id)") { nav.push(CatalogRoute.product(id: id)) }
                }
                .navigationTitle("Catalog")
            case .product(let id):
                VStack(spacing: 16) {
                    Text("Product #\(id)").font(.largeTitle)
                    Button("Back") { nav.pop() }
                }
                .navigationTitle("Product")
            }
        }
    }
}
