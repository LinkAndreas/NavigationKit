import Testing
import NavigationKitTesting
@testable import NavigationKit

@MainActor
private final class Outcome<T> {
    var value: T?
    var calls = 0
    func record(_ value: T?) { self.value = value; calls += 1 }
}

/// Callback calls made from synchronous code, like a button action.
@MainActor
private enum Button {
    static func presentPayment(_ nav: any Navigator, into outcome: Outcome<String>) {
        nav.present(HomeRoute.settings, returning: String.self) { outcome.record($0) }
    }

    static func share(_ nav: any Navigator, copied: Outcome<Bool>, dismissed: Outcome<Bool>) {
        nav.dialog("Share", style: .confirmation) {
            Dialog.Action("Copy Link") { copied.record(true) }
            Dialog.Action("Cancel", role: .cancel)
        } onDismiss: {
            dismissed.record(true)
        }
    }

    static func delete(_ nav: any Navigator, into outcome: Outcome<Bool>) {
        nav.confirm("Delete?", confirm: "Delete", destructive: true) { outcome.record(true) }
    }

    static func checkout(_ nav: any Navigator, into outcome: Outcome<Bool>) {
        nav.flow(FlowRoute.step1) { outcome.record($0) }
    }
}

@MainActor
struct CallbackTests {
    @Test func presentCallsBackWithTheDismissedValue() async {
        let nav = RecordingNavigator()
        nav.results[AnyRoute(HomeRoute.settings)] = "card-1"
        let outcome = Outcome<String>()

        Button.presentPayment(nav, into: outcome)
        await settle()

        #expect(outcome.value == "card-1")
        #expect(outcome.calls == 1)
    }

    @Test func dialogRunsTheChosenActionsHandler() async {
        let nav = RecordingNavigator()
        nav.answerDialogs(with: "Copy Link")
        let copied = Outcome<Bool>(), dismissed = Outcome<Bool>()

        Button.share(nav, copied: copied, dismissed: dismissed)
        await settle()

        #expect(copied.calls == 1)
        #expect(dismissed.calls == 0)
    }

    @Test func dialogCallsOnDismissWhenNothingWasChosen() async {
        let nav = RecordingNavigator()                      // answers nil: dismissed
        let copied = Outcome<Bool>(), dismissed = Outcome<Bool>()

        Button.share(nav, copied: copied, dismissed: dismissed)
        await settle()

        #expect(copied.calls == 0)
        #expect(dismissed.calls == 1)
    }

    @Test func confirmOnlyCallsBackWhenConfirmed() async {
        let declined = RecordingNavigator()
        let confirmed = RecordingNavigator()
        confirmed.answerDialogs(with: "Delete")
        let noCall = Outcome<Bool>(), call = Outcome<Bool>()

        Button.delete(declined, into: noCall)
        Button.delete(confirmed, into: call)
        await settle()

        #expect(noCall.calls == 0)
        #expect(call.calls == 1)
    }

    @Test func flowReportsWhetherItFinished() async {
        let nav = RecordingNavigator()                      // no scripted result: abandoned
        let outcome = Outcome<Bool>()

        Button.checkout(nav, into: outcome)
        await settle()

        #expect(outcome.value == false)
    }
}
