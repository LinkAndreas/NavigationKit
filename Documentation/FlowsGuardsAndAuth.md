# Flows, Guards & Auth

## Flows

A flow is a multi-step process that owns its steps: checkout, onboarding, a verification. It declares its input, its steps and its result; callers only start it, and only the flow can show its steps.

```swift
public struct Checkout: Flow {
    public typealias Result = Order                  // omit for flows that only need to complete
    public let cart: Cart                            // input, available in every step

    public enum Step: Hashable, Codable, Sendable {  // not a Route: nothing outside can push it
        case review, address, payment(Address), done(Order)
    }
    public var start: Step { .review }
}
```

A `Flow` is a plain value in `NavigationKitInterface`, so it can live in a package without SwiftUI.

### Its screens: one `FlowModule`

The whole flow is wired in one `switch`. Each step gets the running flow (with its input) and a `FlowNavigator` typed to this flow:

```swift
struct CheckoutScreens: FlowModule {
    func body(for step: Checkout.Step, in flow: Checkout, navigator: FlowNavigator<Checkout>) -> some View {
        switch step {
        case .review:
            ReviewScreen(cart: flow.cart, onNext: { navigator.next(.address) }, onClose: { navigator.cancel() })
        case .address:
            AddressScreen(onConfirm: { navigator.next(.payment($0)) })
        case let .payment(address):
            PaymentScreen(cart: flow.cart, address: address, onPaid: { navigator.next(.done($0)) })
        case let .done(order):
            DoneScreen(order: order, onClose: { navigator.finish(order) })
        }
    }
}

NavigationRoot { … }.routes(CheckoutScreens())
```

| In a step | Effect |
|---|---|
| `navigator.next(.payment(address))` | show the next step — only this flow's steps compile |
| `navigator.finish(order)` | end the flow and hand `order` to the caller — the type is checked |
| `navigator.finish()` | end a `Void` flow |
| `navigator.cancel()` | end the flow; the caller sees it as abandoned (`nil`) |
| `navigator.pop()`, back swipe | ordinary back navigation between steps |

`FlowNavigator` is a full navigator: `present`, dialogs, `remember` and starting other flows work as everywhere.

### Starting a flow

```swift
navigator.flow(Checkout(cart: cart)) { order in receipt.show(order) }   // runs only if it finishes
let order = await navigator.flow(Checkout(cart: cart))                  // Order?, nil if abandoned
navigator.flow(Checkout(cart: cart), as: .sheet)                        // in a modal
```

Without a style, the flow's own `presentation` trait decides; `nil` pushes it onto the current stack. Its `hidesTabBar` applies to all its steps, and `requiresAuth` gates its start.

Finishing or cancelling unwinds **exactly** the flow's screens, wherever it started — a pushed flow pops them, a presented flow dismisses its modal. Backing out past the first step, or swiping its modal away, abandons it. A screen pushed or presented *from* a step (a help page, a picker sheet) belongs to the flow too: when the flow ends, it goes with it.

### A flow as a tab

A section can host a flow: its steps are the tab's screens, and finishing or cancelling starts it over in a fresh run — with fresh `.flow` dependencies — ready for the next time:

```swift
NavigationRoot {
    RootSection(AppTab.order, "Order", icon: "cart", flow: Checkout()) { order in
        receipts.add(order)                         // called when the flow finishes
    }
    RootSection(AppTab.history, "History", icon: "clock") { HistoryRoute.list }
}
.routes(CheckoutScreens(), HistoryModule())
```

The same works without a result handler wherever a root route goes — `RootSection(…) { Checkout() }`, a split view's `detail:`, or `NavigationRoot(Checkout())` — and a running tab flow is restored with its progress.

### Composing flows

A step runs another flow and continues with its result:

```swift
case .teamDetails:
    TeamDetailsScreen(onProofRequirementSelected: { requirement in
        navigator.flow(ProofFlow(requirement: requirement)) { proof in
            navigator.next(.summary(proof))
        }
    })
```

The inner flow's screens unwind when it finishes, and the outer flow continues from the step that started it — Back from the summary goes to team details. If the user backs out of the inner flow, they're on team details again and nothing else happens. The ShowCase app's hackathon registration works this way.

To keep two flows in separate packages that don't know each other, let the app connect them with a closure: the outer module takes a `(any Navigator, (Address) -> Void) -> Void` and the app passes `{ navigator, done in navigator.flow(AddressFlow()) { done($0) } }`.

### State for one run

```swift
case let .projectUpload(requirement):
    WithDependency(for: .flow) { ProofDraft() } content: { draft in
        ProjectUploadScreen(onNext: { draft.hasDocument = true; navigator.next(.repositoryLink) })
    }
```

Every step of a run gets the same value; it's released when the run's last screen is gone, and the next run starts fresh. A nested flow has its own `.flow`; reach the enclosing one with `.flow(HackathonRegistration.self)`.

### Restoration and deep links

Steps are `Codable` together with their flow, so restoring brings back a running flow with its input, and `finish` still unwinds it (there's no caller left to receive the result). A deep link or `navigate` step can start a flow with `.push(Checkout(cart: cart))`.

## Guards

Protect a screen with unsaved changes:

```swift
Form { … }
    .navigationGuard(when: hasChanges)          // "Discard changes?" confirmation
```

Or decide yourself:

```swift
.navigationGuard(when: hasChanges) {
    await navigator.confirm("Leave without saving?", confirm: "Leave", destructive: true)
}
```

A guard runs whenever its screen would be removed: back navigation, `pop`, `popToRoot`, `dismiss`, a tab switch that has to close modals, and deep links. While active on a pushed screen, the system back button is replaced by a guarded one (which also disables the swipe-back gesture), and interactive dismissal of its modal is disabled — there is no way around the guard. Finishing a flow does not consult guards: the user completed it.

## Auth gate

Mark routes that need a signed-in user, and tell the root how to sign in:

```swift
enum AccountRoute: Route {
    case profile, paymentMethods
    var requiresAuth: Bool { self == .paymentMethods }
}

NavigationRoot { … }
    .authGate(isAuthenticated: { session.isSignedIn }, login: AuthRoute.signIn)
```

Navigating to a gated route while signed out presents the login route first. When the login screen calls `navigator.dismiss(returning: true)` (and `isAuthenticated` now holds), the original navigation continues. Any other dismissal cancels it. Gating applies to `push`, `open`, `present`, `show` and `flow`.
