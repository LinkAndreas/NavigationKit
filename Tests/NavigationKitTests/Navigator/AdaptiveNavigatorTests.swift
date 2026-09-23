import Foundation
import Testing
@testable import NavigationKit

private struct MockRoute: Hashable {
    let id: String
}

@MainActor
private func makeAdaptiveNavigator() -> AdaptiveNavigator {
    AdaptiveNavigator(
        compact: TabsNavigator(tabs: [
            TabsNavigator.Tab(id: "home", title: "Home", systemImage: "house", navigator: StackNavigator(root: MockRoute(id: "home"))),
            TabsNavigator.Tab(id: "settings", title: "Settings", systemImage: "gear", navigator: StackNavigator(root: MockRoute(id: "settings"))),
        ], selection: "home"),
        regular: SplitNavigator(
            sidebar: StackNavigator(root: MockRoute(id: "sidebar")),
            detail: StackNavigator(root: MockRoute(id: "detail"))
        )
    )
}

@Test
@MainActor
func adaptiveNavigatorHasNoLayoutUntilShown() async throws {
    let sut = makeAdaptiveNavigator()

    #expect(sut.layout == nil)
    #expect(sut.activeTabs == nil)
    #expect(sut.activeSplit == nil)
}

@Test
@MainActor
func adaptiveNavigatorExposesOnlyTheLayoutOnScreen() async throws {
    let sut = makeAdaptiveNavigator()

    sut.updateLayout(.compact)
    #expect(sut.activeTabs === sut.compact)
    #expect(sut.activeSplit == nil)

    sut.updateLayout(.regular)
    #expect(sut.activeTabs == nil)
    #expect(sut.activeSplit === sut.regular)
}

@Test
@MainActor
func adaptiveNavigatorReportsEachLayoutChangeOnce() async throws {
    let sut = makeAdaptiveNavigator()
    var changes: [String] = []
    sut.onLayoutChange = { old, new in
        changes.append("\(old.map { "\($0)" } ?? "nil")→\(new)")
    }

    sut.updateLayout(.compact)
    sut.updateLayout(.compact)
    sut.updateLayout(.regular)

    #expect(changes == ["nil→compact", "compact→regular"])
}

@Test
@MainActor
func adaptiveNavigatorLayoutIsSetWhenChangeIsReported() async throws {
    let sut = makeAdaptiveNavigator()
    var activeSplitDuringChange: SplitNavigator?
    sut.onLayoutChange = { _, _ in activeSplitDuringChange = sut.activeSplit }

    sut.updateLayout(.regular)

    #expect(activeSplitDuringChange === sut.regular)
}

@Test
@MainActor
func adaptiveNavigatorKeepsItsModalsAcrossLayoutChanges() async throws {
    let sut = makeAdaptiveNavigator()
    sut.updateLayout(.compact)

    sut.present(fullScreenCover: MockRoute(id: "session"))
    sut.updateLayout(.regular)

    #expect(sut.modals.fullScreenCover?.root == AnyRoute(MockRoute(id: "session")))
}

@Test
@MainActor
func adaptiveNavigatorDismissesModalsInBothLayouts() async throws {
    let sut = makeAdaptiveNavigator()
    sut.present(sheet: MockRoute(id: "root"))
    sut.compact.navigator(for: "home")?.presentSheet(MockRoute(id: "tab"))
    sut.regular.detail.presentSheet(MockRoute(id: "column"))

    sut.dismissAllModals()

    #expect(sut.modals.sheet == nil)
    #expect(sut.compact.navigator(for: "home")?.modals.sheet == nil)
    #expect(sut.regular.detail.modals.sheet == nil)
}

@Test
@MainActor
func deepLinkIntoAdaptiveNavigatorReachesTheMatchingLayout() async throws {
    let sut = makeAdaptiveNavigator()

    applyDeepLink(.tabs(TabsState(selection: "settings")), to: .adaptive(sut))
    #expect(sut.compact.selection == AnyHashable("settings"))

    applyDeepLink(.split(SplitState(detail: StackState(MockRoute(id: "linked")))), to: .adaptive(sut))
    #expect(sut.regular.detail.root == AnyRoute(MockRoute(id: "linked")))
}
