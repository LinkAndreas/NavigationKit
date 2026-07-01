import Foundation
import Testing
@testable import NavigationKit

@Test
func tabsStateInitializationAndModifiers() async throws {
    struct MockTab: Hashable {
        let id: String
    }
    
    let tab1 = MockTab(id: "1")
    let tab2 = MockTab(id: "2")
    
    let tabs = [
        AnyRoute(tab1): StackState(tab1),
        AnyRoute(tab2): StackState(tab2)
    ]
    
    let state = TabsState(selection: AnyRoute(tab1), tabs: tabs)
    
    #expect(state.tabs.count == 2)
    #expect(state.selection == AnyHashable(AnyRoute(tab1)))
    #expect(state.modal == nil)
    
    // Test asState
    let navState = state.asState
    #expect(navState == .tabs(state))
}
