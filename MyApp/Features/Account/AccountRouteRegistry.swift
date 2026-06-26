import SwiftUI

public enum AccountRouteRegistry {
    public static func register(in registry: inout DestinationRegistry) {
        registry.register(AccountRoute.self) { route, nav in
            switch route {
            case .profile:
                List {
                    Button("Settings") { nav.push(AccountRoute.settings) }
                    Button("Close")    { nav.dismiss() }
                }
                .navigationTitle("Account")
            case .settings:
                Text("Settings").navigationTitle("Settings")
            }
        }
    }
}
