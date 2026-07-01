import Foundation
import Testing
@testable import NavigationKit

@Test
@MainActor
func stackNavigatorStackOperations() async throws {
    struct MockRoute: Hashable {
        let id: String
    }

    let root = MockRoute(id: "root")
    let sut = StackNavigator(root: root)

    #expect(sut.path.isEmpty)

    // Push
    let routeA = MockRoute(id: "a")
    sut.push(routeA)
    #expect(sut.path.count == 1)
    #expect(sut.path.first == AnyRoute(routeA))

    // Push multiple
    let routeB = MockRoute(id: "b")
    let routeC = MockRoute(id: "c")
    sut.push(routeB)
    sut.push(routeC)
    #expect(sut.path.count == 3)
    #expect(sut.path.last == AnyRoute(routeC))

    // Pop
    sut.pop()
    #expect(sut.path.count == 2)
    #expect(sut.path.last == AnyRoute(routeB))

    // Pop to root
    sut.popToRoot()
    #expect(sut.path.isEmpty)
}

@Test
@MainActor
func stackNavigatorModalOperations() async throws {
    struct MockRoute: Hashable {
        let id: String
    }

    let root = MockRoute(id: "root")
    let sut = StackNavigator(root: root)

    // Present Sheet
    let sheetRoute = MockRoute(id: "sheet")
    sut.presentSheet(sheetRoute)
    #expect(sut.modals.sheet != nil)
    #expect(sut.modals.sheet?.root == AnyRoute(sheetRoute))

    // Dismiss Sheet
    sut.dismissAllModals()
    #expect(sut.modals.sheet == nil)

    // Present FullScreenCover
    let coverRoute = MockRoute(id: "cover")
    sut.presentFullScreenCover(coverRoute)
    #expect(sut.modals.fullScreenCover != nil)
    #expect(sut.modals.fullScreenCover?.root == AnyRoute(coverRoute))

    // Dismiss FullScreenCover
    sut.dismissAllModals()
    #expect(sut.modals.fullScreenCover == nil)
}

@Test
@MainActor
func stackNavigatorAlertOperations() async throws {
    struct MockRoute: Hashable {
        let id: String
    }

    let sut = StackNavigator(root: MockRoute(id: "root"))

    let alert = AlertSpec(title: "Warning", message: "Message", buttons: [])
    sut.present(alert: alert)
    #expect(sut.modals.alert != nil)
    #expect(sut.modals.alert?.title == "Warning")

    sut.dismissAllModals()
    #expect(sut.modals.alert == nil)

    let dialog = ConfirmationDialogSpec(title: "Confirm", message: "Message", buttons: [])
    sut.present(confirmationDialog: dialog)
    #expect(sut.modals.confirmationDialog != nil)
    #expect(sut.modals.confirmationDialog?.title == "Confirm")

    sut.dismissAllModals()
    #expect(sut.modals.confirmationDialog == nil)
}

@Test
@MainActor
func stackNavigatorApplyState() async throws {
    struct MockRoute: Hashable {
        let id: String
    }

    let sut = StackNavigator(root: MockRoute(id: "root"))
    let state = StackState(MockRoute(id: "root"))
        .pushing(MockRoute(id: "a"))
        .presentingSheet(NavigationState.stack(StackState(MockRoute(id: "sheet_root"))))

    sut.apply(state)

    #expect(sut.path.count == 1)
    #expect(sut.modals.sheet != nil)
    #expect(sut.modals.sheet?.root == AnyRoute(MockRoute(id: "sheet_root")))
}
