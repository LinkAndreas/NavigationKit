import Foundation
import Testing
@testable import NavigationKit

@Test
@MainActor
func splitNavigatorSplitOperations() async throws {
    struct MockRoute: Hashable {
        let id: String
    }

    let sidebar = StackNavigator(root: MockRoute(id: "sidebar"))
    let detail = StackNavigator(root: MockRoute(id: "detail"))
    let sut = SplitNavigator(sidebar: sidebar, detail: detail)

    #expect(sut.sidebar === sidebar)
    #expect(sut.detail === detail)
    #expect(sut.content == nil)
    #expect(sut.columnVisibility == .automatic)

    // showDetail replaces the root and clears the path
    detail.push(MockRoute(id: "pushed"))
    #expect(sut.detail.path.count == 1)

    sut.showDetail(MockRoute(id: "newDetail"))
    #expect(sut.detail.root == AnyRoute(MockRoute(id: "newDetail")))
    #expect(sut.detail.path.isEmpty == true)

    // showContent creates a navigator lazily
    #expect(sut.content == nil)
    sut.showContent(MockRoute(id: "content"))
    #expect(sut.content?.root == AnyRoute(MockRoute(id: "content")))
}

@Test
@MainActor
func splitNavigatorApplySplitState() async throws {
    struct MockRoute: Hashable {
        let id: String
    }

    let sidebar = StackNavigator(root: MockRoute(id: "sidebar"))
    let detail = StackNavigator(root: MockRoute(id: "detail"))
    let sut = SplitNavigator(sidebar: sidebar, detail: detail)

    let state = SplitState(
        sidebar: StackState(MockRoute(id: "sidebar")).pushing(MockRoute(id: "a")),
        detail: StackState(MockRoute(id: "newDetail")),
        columnVisibility: .doubleColumn
    )

    sut.apply(state)

    #expect(sut.sidebar.path.count == 1)
    #expect(sut.detail.root == AnyRoute(MockRoute(id: "newDetail")))
    #expect(sut.columnVisibility == .doubleColumn)
}
