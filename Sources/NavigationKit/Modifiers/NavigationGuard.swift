import SwiftUI

public extension View {
    /// Protects this screen from being left while `isActive` — by back navigation, dismissal,
    /// a tab switch with modals open, or a deep link. `shouldLeave` decides; return `false` to stay.
    ///
    /// While active, the native back button and swipe-to-dismiss are replaced by guarded
    /// equivalents, so there is no way around the guard.
    func navigationGuard(when isActive: Bool, _ shouldLeave: @escaping @MainActor () async -> Bool) -> some View {
        modifier(NavigationGuardModifier(isActive: isActive, shouldLeave: { _ in await shouldLeave() }))
    }

    /// Guards this screen with a ready-made "discard changes?" confirmation.
    func navigationGuard(
        when isActive: Bool,
        confirm title: String = "Discard changes?",
        message: String? = nil,
        discard: String = "Discard"
    ) -> some View {
        modifier(NavigationGuardModifier(isActive: isActive) { navigator in
            await navigator.confirm(title, message: message, confirm: discard, destructive: true)
        })
    }
}

struct NavigationGuardModifier: ViewModifier {
    let isActive: Bool
    let shouldLeave: @MainActor (any Navigator) async -> Bool
    @Environment(\.screenContext) private var context
    @Environment(\.navigator) private var navigator

    func body(content: Content) -> some View {
        let showsGuardedBack = isActive && context.map { !$0.isRoot } == true
        content
            .onChange(of: isActive, initial: true) { _, active in
                guard let context else { return }
                if active {
                    let navigator = navigator
                    context.stack.guards[context.entryID] = { await shouldLeave(navigator) }
                } else {
                    context.stack.guards[context.entryID] = nil
                }
            }
            #if os(iOS)
            .navigationBarBackButtonHidden(showsGuardedBack)
            .toolbar {
                if showsGuardedBack {
                    ToolbarItem(placement: .topBarLeading) {
                        Button { navigator.pop() } label: {
                            Label("Back", systemImage: "chevron.backward")
                        }
                    }
                }
            }
            #endif
            .interactiveDismissDisabled(isActive)
    }
}
