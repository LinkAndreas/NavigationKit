import Foundation
import Testing
@testable import NavigationKit

@Test
@MainActor
func tabsNavigatorTabsOperations() async throws {
    struct MockRoute: Hashable {
        let id: String
    }

    let tabA = AnyRoute(MockRoute(id: "a"))
    let tabB = AnyRoute(MockRoute(id: "b"))
    let tabs = [
        TabsNavigator.Tab(id: tabA, title: "A", systemImage: "a", navigator: StackNavigator(root: tabA)),
        TabsNavigator.Tab(id: tabB, title: "B", systemImage: "b", navigator: StackNavigator(root: tabB))
    ]

    let sut = TabsNavigator(tabs: tabs, selection: tabA)
    #expect(sut.selection == AnyHashable(tabA))

    sut.select(tabB)
    #expect(sut.selection == AnyHashable(tabB))
}
