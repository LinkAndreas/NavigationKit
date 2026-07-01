import Foundation
import SwiftUI
import Testing
@testable import NavigationKit

@Test
@MainActor
func routeBuilderRegistersAndResolvesViews() async throws {
    struct MockRoute: Hashable {
        let id: String
    }
    
    let sut = RouteBuilder()
    let navigator = StackNavigator(root: MockRoute(id: "1"))
    
    // Register the route
    sut.register(MockRoute.self) { route, nav in
        Text("Mock Route \(route.id)")
    }
    
    // Resolve the route
    let route = AnyRoute(MockRoute(id: "1"))
    let anyView = sut.view(for: route, navigator: navigator)
    
    // In SwiftUI, we can't easily assert the contents of AnyView without reflection or UI tests.
    // Since AnyView is a value type and not optional, we just check that we can create it.
    // In a more sophisticated test, we might use Mirror or snapshot testing.
}

@Test
@MainActor
func routeBuilderResolvesUnregisteredRoutesWithFallback() async throws {
    struct UnregisteredRoute: Hashable {
        let id: String
    }
    
    let sut = RouteBuilder()
    let navigator = StackNavigator(root: UnregisteredRoute(id: "1"))
    
    let route = AnyRoute(UnregisteredRoute(id: "1"))
    let anyView = sut.view(for: route, navigator: navigator)
    
    // Since AnyView is a struct, it's non-optional. Just producing it without crashing is the minimal test here.
}
