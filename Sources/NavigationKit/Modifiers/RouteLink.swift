import SwiftUI

public extension View {
    /// Marks this view as the source a `.cover(zoomFrom:)` presentation zooms out of.
    func navigationZoomSource(_ id: String) -> some View {
        modifier(ZoomSourceModifier(id: id))
    }
}

struct ZoomSourceModifier: ViewModifier {
    let id: String
    @Environment(\.navigationZoomNamespace) private var namespace

    func body(content: Content) -> some View {
        #if os(iOS)
        if let namespace {
            content.matchedTransitionSource(id: id, in: namespace)
        } else {
            content
        }
        #else
        content
        #endif
    }
}

/// A native `NavigationLink` that pushes a `Route` — the escape hatch for adopting
/// NavigationKit screen by screen, or when you want link semantics (e.g. list row chevrons and
/// selection highlighting) instead of an imperative `push`.
public struct RouteLink<Label: View>: View {
    private let route: AnyRoute
    private let label: Label

    public init<R: Route>(_ route: R, @ViewBuilder label: () -> Label) {
        self.route = AnyRoute(route)
        self.label = label()
    }

    public var body: some View {
        NavigationLink(value: Entry(route: route)) { label }
    }
}

public extension RouteLink where Label == Text {
    init<R: Route>(_ title: String, route: R) {
        self.init(route) { Text(title) }
    }
}

/// A window group that opens routes presented with `.window`. Add it next to your main window:
///
/// ```swift
/// var body: some Scene {
///     WindowGroup { ContentView() }
///     RouteWindows(ScheduleModule(), SpeakersModule())
/// }
/// ```
public struct RouteWindows: Scene {
    private let registry: RouteRegistry

    public init(_ modules: any RouteModule...) {
        registry = RouteRegistry(modules)
    }

    public init(registry: RouteRegistry) {
        self.registry = registry
    }

    public var body: some Scene {
        WindowGroup(for: AnyRoute.self) { $route in
            if let route {
                NavigationRoot(root: route).routes(registry)
            }
        }
    }
}

public extension ViewRoute {
    /// A screen in a working navigation context, for `#Preview`:
    /// `#Preview { SpeakersRoute.detail(id: "s1").preview() }`.
    @MainActor func preview() -> some View {
        NavigationRoot(self)
    }
}

public extension Route {
    /// A screen in a working navigation context, for `#Preview`, using `modules` to resolve views.
    @MainActor func preview(using modules: any RouteModule...) -> some View {
        NavigationRoot(self).routes(RouteRegistry(modules))
    }
}
