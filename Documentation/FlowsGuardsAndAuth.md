# Flows, Guards & Auth

## Flows

A flow is a multi-step process that produces a result: checkout, onboarding, a verification. Declare it once, and anyone can start it — or run it as one step of their own flow — without knowing its screens.

```swift
public struct Checkout: Flow {
    public typealias Result = Order          // omit for flows that only need to complete
    public var start: CheckoutRoute { .cart }
}
```

A `Flow` is a plain `Route` (it lives in `NavigationKitInterface`, no SwiftUI), so it can have parameters and sit in a contracts package. Its steps are ordinary routes whose screens come from a module, like any other.

### Starting a flow

```swift
nav.flow(Checkout()) { order in receipt.show(order) }   // runs only if the flow finishes
let order = await nav.flow(Checkout())                  // Order?, nil if the user backed out
nav.flow(Checkout(), as: .sheet)                        // in a modal
```

On screen, a flow *is* its start step. Without a style, the start step's `presentation` trait decides — a flow whose first step is a sheet runs in a sheet; otherwise it's pushed onto the current stack. The flow also takes `requiresAuth` and `hidesTabBar` from its start step.

### Inside a flow

Steps continue, finish or cancel; they never name the screen to return to:

```swift
struct CheckoutScreens: TypedRouteModule {
    func body(for route: CheckoutRoute, nav: RouteNavigator<CheckoutRoute>) -> some View {
        switch route {
        case .cart:
            CartScreen(onNext: { nav.push(.payment) }, onClose: { nav.cancelFlow() })
        case .payment:
            PaymentScreen(onPaid: { order in nav.finishFlow(returning: order) })
        }
    }
}
```

- `finishFlow(returning:)` unwinds **exactly** the screens the flow added — wherever it started — and hands the result to the caller. A pushed flow pops its screens; a presented flow dismisses its modal.
- `cancelFlow()` unwinds the same screens, and the caller sees the flow as abandoned (`nil`).
- Backing out past the first step, or swiping its modal away, also abandons it.

### Composing flows

Run another flow as one step, and continue with its result:

```swift
case .teamDetails:
    TeamDetailsScreen { requirement in
        nav.flow(ProofFlow(requirement: requirement)) { proof in
            nav.push(.summary(proof))
        }
    }
```

The inner flow's screens are unwound when it finishes, and the outer flow continues from the step that started it — so Back from the summary goes to team details, not into the proof screens. If the user backs out of the inner flow, they're on team details again and nothing else happens.

The ShowCase app's hackathon registration works this way: `HackathonRegistration` runs `ProofFlow`, which another team could own and reuse.

### Flows from plain routes

A flow can also start at a route directly: `nav.flow(CheckoutRoute.cart, returning: Order.self)`. Steps work the same; declaring a `Flow` adds the typed result and a name callers can reuse.

## Guards

Protect a screen with unsaved changes:

```swift
Form { … }
    .navigationGuard(when: hasChanges)          // "Discard changes?" confirmation
```

Or decide yourself:

```swift
.navigationGuard(when: hasChanges) {
    await nav.confirm("Leave without saving?", confirm: "Leave", destructive: true)
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

Navigating to a gated route while signed out presents the login route first. When the login screen calls `nav.dismiss(returning: true)` (and `isAuthenticated` now holds), the original navigation continues. Any other dismissal cancels it. Gating applies to `push`, `open`, `present`, `show` and `flow`.
