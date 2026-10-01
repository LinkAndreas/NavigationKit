import SwiftUI

/// The single entry point: declare your app's sections once, pick a layout, and every screen
/// below gets a navigator scoped to where it is.
///
/// ```swift
/// NavigationRoot(selection: AppTab.discover) {
///     RootSection(AppTab.discover, "Discover", icon: "sparkles") { DiscoverRoute.home }
///     RootSection(AppTab.schedule, "Schedule", icon: "calendar") { ScheduleRoute.list }
/// }
/// .layout(.adaptive)
/// .routes(ScheduleModule(), SpeakersModule())
/// .deepLinks(AppLinks.self)
/// .restoration(.sceneStorage("nav"))
/// ```
public struct NavigationRoot: View {
    @State private var store: NavigationStore
    @State private var registryCache = RegistryCache()
    @Namespace private var zoomNamespace
    @Environment(\.supportsMultipleWindows) private var supportsMultipleWindows
    @Environment(\.openWindow) private var openWindow
    @Environment(\.scenePhase) private var scenePhase

    private var layout: NavigationLayout?
    private var registry: RouteRegistry?
    private var modules: [any RouteModule] = []
    private var deepLinks: (@MainActor (URL) -> [Step]?)?
    private var authCheck: (@MainActor () -> Bool)?
    private var loginRoute: AnyRoute?
    private var eventHandlers: [@MainActor (NavigationEvent) -> Void] = []
    private var restoration: Restoration?
    private var handoffActivityType: String?
    private var accessories: [(NavigationStore) -> AnyView] = []

    // MARK: Init

    /// A single stack starting at `root`.
    public init<R: Route>(_ root: R) {
        _store = State(initialValue: NavigationStore(root: root))
    }

    init(root: AnyRoute) {
        _store = State(initialValue: NavigationStore(root: root))
    }

    /// Top-level sections; the first one is selected initially.
    public init(@RootSectionsBuilder sections: () -> [RootSection]) {
        _store = State(initialValue: NavigationStore(layout: .adaptive, sections: sections()))
    }

    /// Top-level sections with an initial selection.
    public init<ID: Hashable & Sendable>(selection: ID, @RootSectionsBuilder sections: () -> [RootSection]) {
        _store = State(initialValue: NavigationStore(layout: .adaptive, selection: selection, sections: sections()))
    }

    /// Top-level sections with your own sidebar, shown whenever the layout has one (`.split`, or
    /// `.adaptive` in a wide window). Like `NavigationSplitView`'s sidebar, it receives the
    /// selection; setting it switches sections exactly as tapping the built-in sidebar would.
    ///
    /// ```swift
    /// NavigationRoot(selection: Section.connect) {
    ///     RootSection(Section.connect, "Connect") { ConnectRoute.home }
    ///     RootSection(Section.history, "History") { HistoryRoute.list }
    /// } sidebar: { selection in
    ///     MySidebar(selection: selection)
    /// }
    /// .layout(.split)
    /// ```
    public init<ID: Hashable & Sendable, Sidebar: View>(
        selection: ID,
        @RootSectionsBuilder sections: () -> [RootSection],
        @ViewBuilder sidebar: @escaping (Binding<ID>) -> Sidebar
    ) {
        let store = NavigationStore(layout: .adaptive, selection: selection, sections: sections())
        store.customSidebar = Self.sidebarContent(selection, sidebar)
        _store = State(initialValue: store)
    }

    /// Renders a store you own — for navigating from outside the view hierarchy, or in tests.
    public init(store: NavigationStore) {
        _store = State(initialValue: store)
    }

    /// Renders a store you own with your own sidebar. `selection` is shown until the store
    /// reports a selection of type `ID`; see ``init(selection:sections:sidebar:)``.
    public init<ID: Hashable & Sendable, Sidebar: View>(
        store: NavigationStore,
        selection: ID,
        @ViewBuilder sidebar: @escaping (Binding<ID>) -> Sidebar
    ) {
        store.customSidebar = Self.sidebarContent(selection, sidebar)
        _store = State(initialValue: store)
    }

    private static func sidebarContent<ID: Hashable & Sendable, Sidebar: View>(
        _ fallback: ID,
        _ sidebar: @escaping (Binding<ID>) -> Sidebar
    ) -> CustomSidebar {
        CustomSidebar { store in
            AnyView(sidebar(store.selectionBinding(fallback: fallback)))
        }
    }

    // MARK: Body

    public var body: some View {
        let store = configuredStore
        RootLayoutView(store: store)
            .environment(\.routeRegistry, resolvedRegistry)
            .environment(\.navigationStore, store)
            .environment(\.navigationZoomNamespace, zoomNamespace)
            .modifier(RestorationModifier(store: store, restoration: restoration))
            .modifier(HandoffModifier(store: store, activityType: handoffActivityType))
            .onOpenURL { url in
                if deepLinks != nil { store.open(url) }
            }
            .onAppear {
                store.isAttached = true
                store.supportsMultipleWindows = supportsMultipleWindows
                store.openWindow = { route in openWindow(value: route) }
            }
            .onDisappear { store.isAttached = false }
            .onChange(of: scenePhase, initial: true) { _, phase in
                if phase == .active { store.sceneIsActive.set() }
            }
            .overlay {
                ForEach(accessories.indices, id: \.self) { index in
                    accessories[index](store)
                }
            }
    }

    /// Applies the declarative configuration to the store. Only non-observed properties are
    /// touched, so this is safe during a view update.
    private var configuredStore: NavigationStore {
        if let layout { store.layout = layout }
        store.deepLinkHandler = deepLinks
        store.authCheck = authCheck
        store.loginRoute = loginRoute
        store.eventHandlers = eventHandlers
        return store
    }

    /// Built once: modules are static configuration, and a stable registry instance keeps the
    /// environment from invalidating every screen on each root update.
    private var resolvedRegistry: RouteRegistry? {
        if modules.isEmpty { return registry }
        if let cached = registryCache.registry { return cached }
        let combined = registry ?? RouteRegistry()
        modules.forEach { combined.add($0) }
        registryCache.registry = combined
        return combined
    }

    // MARK: Configuration

    /// How sections are laid out. Defaults to `.adaptive` (and `.stack` for a single root).
    public func layout(_ layout: NavigationLayout) -> NavigationRoot {
        var copy = self
        copy.layout = layout
        return copy
    }

    /// Feature modules that map routes to views (only needed for routes that aren't ``ViewRoute``s).
    public func routes(_ modules: any RouteModule...) -> NavigationRoot {
        var copy = self
        copy.modules += modules
        return copy
    }

    /// Feature modules that map routes to views, as an array.
    public func routes(_ modules: [any RouteModule]) -> NavigationRoot {
        var copy = self
        copy.modules += modules
        return copy
    }

    /// A prebuilt registry, e.g. one shared with ``RouteWindows``.
    public func routes(_ registry: RouteRegistry) -> NavigationRoot {
        var copy = self
        copy.registry = registry
        return copy
    }

    /// Handles incoming URLs (`onOpenURL`) and `Navigator.open(_:)` with `links`.
    public func deepLinks<Links: DeepLinks>(_ links: Links.Type) -> NavigationRoot {
        deepLinks { url in Links.steps(for: url) }
    }

    /// Handles incoming URLs (`onOpenURL`) and `Navigator.open(_:)` with a closure.
    public func deepLinks(_ handler: @escaping @MainActor (URL) -> [Step]?) -> NavigationRoot {
        var copy = self
        copy.deepLinks = handler
        return copy
    }

    /// Routes with `Route/requiresAuth` first present `login` when `isAuthenticated` is false,
    /// then continue to their destination once the login screen calls `nav.dismiss(returning: true)`.
    public func authGate<Login: Route>(isAuthenticated: @escaping @MainActor () -> Bool, login: Login) -> NavigationRoot {
        var copy = self
        copy.authCheck = isAuthenticated
        copy.loginRoute = AnyRoute(login)
        return copy
    }

    /// Observes every navigation event — the single hook for analytics and logging.
    public func onNavigationEvent(_ handler: @escaping @MainActor (NavigationEvent) -> Void) -> NavigationRoot {
        var copy = self
        copy.eventHandlers.append(handler)
        return copy
    }

    /// Persists and restores the navigation state.
    public func restoration(_ restoration: Restoration) -> NavigationRoot {
        var copy = self
        copy.restoration = restoration
        return copy
    }

    /// Publishes the current location as an `NSUserActivity` (Handoff, Spotlight) and restores
    /// it when the activity is continued on another device.
    public func handoff(activityType: String) -> NavigationRoot {
        var copy = self
        copy.handoffActivityType = activityType
        return copy
    }

    /// Overlays a view that has access to the store — used by `NavigationKitDebug`.
    public func accessory<Content: View>(@ViewBuilder _ content: @escaping (NavigationStore) -> Content) -> NavigationRoot {
        var copy = self
        copy.accessories.append { AnyView(content($0)) }
        return copy
    }
}

@MainActor
final class RegistryCache {
    var registry: RouteRegistry?
}

// MARK: - Restoration

/// Where ``NavigationRoot/restoration(_:)`` keeps its data.
public struct Restoration: Sendable {
    enum Storage: Sendable {
        case sceneStorage(String)
        case userDefaults(String)
        case custom(load: @MainActor @Sendable () -> Data?, save: @MainActor @Sendable (Data) -> Void)
    }

    let storage: Storage

    /// Per-scene storage managed by the system — the right choice for most apps.
    public static func sceneStorage(_ key: String) -> Restoration { .init(storage: .sceneStorage(key)) }

    /// `UserDefaults.standard`, shared by all scenes.
    public static func userDefaults(_ key: String) -> Restoration { .init(storage: .userDefaults(key)) }

    /// Your own persistence.
    public static func custom(
        load: @escaping @MainActor @Sendable () -> Data?,
        save: @escaping @MainActor @Sendable (Data) -> Void
    ) -> Restoration {
        .init(storage: .custom(load: load, save: save))
    }
}

struct RestorationModifier: ViewModifier {
    let store: NavigationStore
    let restoration: Restoration?

    func body(content: Content) -> some View {
        switch restoration?.storage {
        case let .sceneStorage(key):
            content.modifier(SceneStorageRestoration(store: store, key: key))
        case let .userDefaults(key):
            content.modifier(DataRestoration(
                store: store,
                load: { UserDefaults.standard.data(forKey: key) },
                save: { UserDefaults.standard.set($0, forKey: key) }
            ))
        case let .custom(load, save):
            content.modifier(DataRestoration(store: store, load: load, save: save))
        case nil:
            content
        }
    }
}

struct SceneStorageRestoration: ViewModifier {
    let store: NavigationStore
    @SceneStorage private var data: Data

    init(store: NavigationStore, key: String) {
        self.store = store
        _data = SceneStorage(wrappedValue: Data(), key)
    }

    func body(content: Content) -> some View {
        content.modifier(DataRestoration(
            store: store,
            load: { data.isEmpty ? nil : data },
            save: { data = $0 }
        ))
    }
}

struct DataRestoration: ViewModifier {
    let store: NavigationStore
    let load: @MainActor () -> Data?
    let save: @MainActor (Data) -> Void

    func body(content: Content) -> some View {
        content
            .task {
                guard !store.didRestore else { return }
                store.didRestore = true
                guard let data = load(),
                      let snapshot = try? JSONDecoder().decode(NavigationSnapshot.self, from: data)
                else { return }
                await store.restore(snapshot)
            }
            .onChange(of: store.snapshot) { _, snapshot in
                guard store.didRestore, let data = try? JSONEncoder().encode(snapshot) else { return }
                save(data)
            }
    }
}

// MARK: - Handoff

struct HandoffModifier: ViewModifier {
    let store: NavigationStore
    let activityType: String?
    static let userInfoKey = "NavigationKit.snapshot"

    func body(content: Content) -> some View {
        if let activityType {
            content
                .userActivity(activityType, element: try? JSONEncoder().encode(store.snapshot)) { data, activity in
                    activity.isEligibleForHandoff = true
                    activity.addUserInfoEntries(from: [Self.userInfoKey: data])
                }
                .onContinueUserActivity(activityType) { activity in
                    guard let data = activity.userInfo?[Self.userInfoKey] as? Data,
                          let snapshot = try? JSONDecoder().decode(NavigationSnapshot.self, from: data)
                    else { return }
                    Task { await store.restore(snapshot) }
                }
        } else {
            content
        }
    }
}

/// A sidebar view supplied through `NavigationRoot`'s `sidebar:` initializers.
struct CustomSidebar {
    let content: @MainActor (NavigationStore) -> AnyView
}

extension NavigationStore {
    /// The selected section as a binding, for custom sidebars. Setting it behaves like a tap on
    /// the built-in sidebar; ids that aren't a section are ignored.
    func selectionBinding<ID: Hashable & Sendable>(fallback: ID) -> Binding<ID> {
        Binding(
            get: { self.selection(as: ID.self) ?? fallback },
            set: { id in
                guard let index = self.sections.firstIndex(where: { $0.id == AnySectionID(id) }) else { return }
                self.userSelect(index)
            }
        )
    }
}
