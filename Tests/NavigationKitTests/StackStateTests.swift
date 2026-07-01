import Foundation
import Testing
@testable import NavigationKit

@Test
func stackStateInitializationAndModifiers() async throws {
    struct MockRoute: Hashable {
        let id: String
    }
    
    // Test Init
    let root = MockRoute(id: "root")
    var state = StackState(root)
    #expect(state.root == AnyRoute(root))
    #expect(state.path.isEmpty)
    #expect(state.modal == nil)
    
    // Test pushing single
    let routeA = MockRoute(id: "a")
    state = state.pushing(routeA)
    #expect(state.path == [AnyRoute(routeA)])
    
    // Test pushing multiple
    let routeB = MockRoute(id: "b")
    let routeC = MockRoute(id: "c")
    state = state.pushing(all: [routeB, routeC])
    #expect(state.path == [AnyRoute(routeA), AnyRoute(routeB), AnyRoute(routeC)])
    
    // Test presenting sheet
    let sheetState = NavigationState.stack(StackState(MockRoute(id: "sheet_root")))
    state = state.presentingSheet(sheetState)
    #expect(state.modal == .sheet(sheetState))
    
    // Test asState
    let navState = state.asState
    #expect(navState == .stack(state))
}
