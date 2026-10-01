# Flows, Guards & Auth

## Flows

A flow is a multi-step process that produces a result: checkout, onboarding, a redemption wizard. Start it, await it, and let any step finish it:

```swift
// Dashboard
let order = await nav.flow(CheckoutRoute.cart, returning: Order.self)

// Any later step in the flow
nav.push(CheckoutRoute.payment)
nav.finishFlow(returning: order)
```

Without a style, the flow is pushed onto the current stack, and `finishFlow` pops **exactly** the screens the flow added — wherever it started. Steps never name the screen to return to. With a style (`nav.flow(route, as: .sheet, returning:)`), the flow runs in a modal and finishing dismisses it.

If the user backs out (pops past the flow's first screen, or dismisses its modal), the await returns `nil`. `flow(_:)` without `returning:` returns `true` if finished, `false` if abandoned.

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
