import SwiftUI

/// Renders one `StackNode`: a `NavigationStack` plus whatever it presents.
struct StackView: View {
    let stack: StackNode

    var body: some View {
        NavigationStack(path: Binding(
            get: { stack.path },
            set: { newPath in
                if let store = stack.store {
                    store.userSetPath(newPath, on: stack)
                } else {
                    stack.setPath(newPath)
                }
            }
        )) {
            ScreenView(entry: stack.rootEntry, stack: stack)
                .id(stack.rootEntry.id)
                .navigationDestination(for: Entry.self) { entry in
                    ScreenView(entry: entry, stack: stack)
                }
        }
        // Split columns get their inspector from the split view, and modals present inspectors as
        // sheets: an inspector wrapping a modal's stack hides the screen's presentation settings,
        // such as interactiveDismissDisabled, from the sheet.
        .modifier(InspectorPresentationModifier(stacks: stack.isSplitColumn || stack.presentingModal != nil ? [] : [stack]))
        .modifier(ModalPresentationModifier(stack: stack))
    }
}

/// Renders one screen: resolves its view and scopes the environment to it.
struct ScreenView: View {
    let entry: Entry
    let stack: StackNode
    @Environment(\.routeRegistry) private var registry

    var body: some View {
        let navigator = ScopedNavigator(stack: stack, entryID: entry.id)
        RouteRegistry.resolve(entry.route, navigator: navigator, registry: registry)
            .environment(\.navigator, navigator)
            .environment(\.screenContext, ScreenContext(stack: stack, entryID: entry.id, isRoot: entry.id == stack.rootEntry.id))
            .modifier(DialogPresentationModifier(stack: stack, entryID: entry.id))
            #if os(iOS)
            .toolbar(entry.route.hidesTabBar ? .hidden : .automatic, for: .tabBar)
            #endif
    }
}

/// The contents of a modal: its own stack, plus detents, zoom transition, and lifecycle signals
/// that let the store sequence nested presentations without timers.
struct ModalContentView: View {
    let modal: ModalNode
    @Environment(\.navigationZoomNamespace) private var namespace

    var body: some View {
        StackView(stack: modal.stack)
            .modifier(DetentsModifier(detents: modal.style.detents))
            .modifier(ZoomTransitionModifier(sourceID: modal.style.zoomSourceID, namespace: namespace))
            // Only while guarded, and in the background so the stack keeps its identity: any
            // interactiveDismissDisabled(false) here would override a screen that disables
            // interactive dismissal itself.
            .background {
                if modal.stack.hasActiveGuard {
                    Color.clear.interactiveDismissDisabled()
                }
            }
            .onAppear { modal.appeared.set() }
            .onDisappear { modal.disappeared.set() }
    }
}

struct DetentsModifier: ViewModifier {
    let detents: [Detent]

    func body(content: Content) -> some View {
        if detents.isEmpty {
            content
        } else {
            content.presentationDetents(Set(detents.map(\.presentationDetent)))
        }
    }
}

extension Detent {
    var presentationDetent: PresentationDetent {
        switch self {
        case .medium: .medium
        case .large: .large
        case let .fraction(value): .fraction(value)
        case let .height(value): .height(value)
        }
    }
}

struct ZoomTransitionModifier: ViewModifier {
    let sourceID: String?
    let namespace: Namespace.ID?

    func body(content: Content) -> some View {
        #if os(iOS)
        if let sourceID, let namespace {
            content.navigationTransition(.zoom(sourceID: sourceID, in: namespace))
        } else {
            content
        }
        #else
        content
        #endif
    }
}
