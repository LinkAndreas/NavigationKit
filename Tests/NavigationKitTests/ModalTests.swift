import Foundation
import Testing
@testable import NavigationKit

@MainActor
struct ModalTests {
    @Test func presentDefaultsToSheetAndPushesInsideIt() {
        let store = NavigationStore(root: HomeRoute.feed)
        let nav = store.navigator
        nav.present(ScheduleRoute.list)
        nav.push(ScheduleRoute.session(id: "1"))   // active navigator follows the modal

        #expect(store.currentSteps == [
            .present(route: AnyRoute(ScheduleRoute.list), style: .sheet),
            .push(ScheduleRoute.session(id: "1")),
        ])

        nav.dismiss()
        #expect(store.currentSteps.isEmpty)
    }

    @Test func presentReturningDeliversResult() async {
        let store = NavigationStore(root: HomeRoute.feed)
        let nav = store.navigator

        async let picked = nav.present(ScheduleRoute.list, returning: String.self)
        await settle()
        nav.dismiss(returning: "blue")

        #expect(await picked == "blue")
        #expect(store.currentSteps.isEmpty)
    }

    @Test func userDismissalYieldsNil() async {
        let store = NavigationStore(root: HomeRoute.feed)
        async let picked = store.navigator.present(ScheduleRoute.list, returning: String.self)
        await settle()

        // Simulates a swipe-down: the sheet binding is set to nil.
        let modal = try! #require(store.sections[0].main.modal)
        store.closeModal(modal, result: nil)

        #expect(await picked == nil)
    }

    @Test func dismissingOuterModalCancelsNestedOnes() async {
        let store = NavigationStore(root: HomeRoute.feed)
        let nav = store.navigator
        nav.present(ScheduleRoute.list)
        async let inner = nav.present(ScheduleRoute.session(id: "1"), returning: Int.self)
        await settle()

        let outer = try! #require(store.sections[0].main.modal)
        store.closeModal(outer, result: nil)

        #expect(await inner == nil)
        #expect(store.currentSteps.isEmpty)
    }

    @Test func dialogReturnsChosenAction() async {
        let store = NavigationStore(root: HomeRoute.feed)
        async let confirmed = store.navigator.confirm("Delete?", confirm: "Delete", destructive: true)
        await settle()

        let stack = store.sections[0].main
        let request = try! #require(stack.dialog)
        let delete = try! #require(request.dialog.actions.first { $0.role == .destructive })
        store.resolveDialog(on: stack, with: delete)

        #expect(await confirmed)
    }

    @Test func dialogBuilderReturnsCancelIDForCancelRole() async {
        let store = NavigationStore(root: HomeRoute.feed)
        async let choice = store.navigator.dialog("Share", style: .confirmation) {
            Dialog.Action("Copy Link", id: "copy")
            Dialog.Action("Close", role: .cancel)
        }
        await settle()

        let stack = store.sections[0].main
        let request = try! #require(stack.dialog)
        #expect(request.dialog.actions.map(\.id) == ["copy", Dialog.Action.cancelID])
        store.resolveDialog(on: stack, with: request.dialog.actions[1])

        #expect(await choice == Dialog.Action.cancelID)
    }
}
