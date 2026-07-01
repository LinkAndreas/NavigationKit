import Foundation
import Testing
@testable import NavigationKit

@Test
func anyRouteEquality() async throws {
    struct MockRoute: Hashable {
        let id: String
    }
    
    struct OtherRoute: Hashable {
        let id: String
    }
    
    let routeA1 = AnyRoute(MockRoute(id: "1"))
    let routeA2 = AnyRoute(MockRoute(id: "1"))
    let routeB = AnyRoute(MockRoute(id: "2"))
    let otherRoute = AnyRoute(OtherRoute(id: "1"))
    
    #expect(routeA1 == routeA2)
    #expect(routeA1 != routeB)
    #expect(routeA1 != otherRoute)
}

@Test
func anyRouteHashing() async throws {
    struct MockRoute: Hashable {
        let id: String
    }
    
    let routeA1 = AnyRoute(MockRoute(id: "1"))
    let routeA2 = AnyRoute(MockRoute(id: "1"))
    
    #expect(routeA1.hashValue == routeA2.hashValue)
    
    var set = Set<AnyRoute>()
    set.insert(routeA1)
    set.insert(routeA2) // Should not increase count since they are equal and have same hash
    
    #expect(set.count == 1)
}
