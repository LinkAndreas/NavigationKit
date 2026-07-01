import Foundation
import Testing
@testable import NavigationKit

@Test
func splitStateInitializationAndModifiers() async throws {
    struct MockRoute: Hashable {
        let id: String
    }

    let sidebar = StackState(MockRoute(id: "sidebar"))
    let detail = StackState(MockRoute(id: "detail"))

    let state = SplitState(sidebar: sidebar, detail: detail, columnVisibility: .all)

    #expect(state.sidebar == sidebar)
    #expect(state.content == nil)
    #expect(state.detail == detail)
    #expect(state.columnVisibility == .all)
    #expect(state.modal == nil)

    // Test asState
    let navState = state.asState
    #expect(navState == .split(state))

    // Test presentingSheet
    let sheetState = state.presentingSheet(.stack(StackState(MockRoute(id: "sheet"))))
    #expect(sheetState.modal == .sheet(.stack(StackState(MockRoute(id: "sheet")))))
}
