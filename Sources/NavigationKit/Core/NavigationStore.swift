import Foundation
import Observation

/// The whole navigation tree of one window, as observable data.
///
/// You usually let ``NavigationRoot`` own the store. Create one yourself when app code outside
/// the view hierarchy needs to navigate (push notifications, App Intents) or in tests — the
/// store works headless, without any views.
///
/// ```swift
/// let store = NavigationStore(sections: [
///     RootSection(AppTab.schedule, "Schedule") { ScheduleRoute.list },
/// ])
/// store.navigator.push(ScheduleRoute.session(id: "42"))
/// #expect(store.currentSteps == [.select(AppTab.schedule), .push(ScheduleRoute.session(id: "42"))])
/// ```
@Observable @MainActor
public final class NavigationStore {
    // MARK: State

    private(set) var sections: [SectionNode]
    var selectionIndex: Int
    public private(set) var recentEvents: [NavigationEvent] = []

    // MARK: Configuration (set by NavigationRoot; not observed)

    @ObservationIgnored var layout: NavigationLayout
    private(set) var isRegularWidth = false
    @ObservationIgnored var isAttached = false
    @ObservationIgnored var supportsMultipleWindows = false
    @ObservationIgnored var openWindow: (@MainActor (AnyRoute) -> Void)?
    @ObservationIgnored var deepLinkHandler: (@MainActor (URL) -> [Step]?)?
    @ObservationIgnored var authCheck: (@MainActor () -> Bool)?
    @ObservationIgnored var loginRoute: AnyRoute?
    @ObservationIgnored var eventHandlers: [@MainActor (NavigationEvent) -> Void] = []
    @ObservationIgnored var didRestore = false
    @ObservationIgnored private var eventContinuations: [UUID: AsyncStream<NavigationEvent>.Continuation] = [:]

    static let singleSectionID = AnySectionID("NavigationKit.main")

    // MARK: Init

    /// A single stack starting at `root`.
    public convenience init<R: Route>(root: R) {
        self.init(root: AnyRoute(root))
    }

    convenience init(root: AnyRoute) {
        self.init(
            layout: .stack,
            sections: [RootSection(id: Self.singleSectionID, title: "", icon: nil, root: root, detail: nil)],
            selection: nil
        )
    }

    /// Top-level sections rendered as tabs, a sidebar, or both (`.adaptive`).
    public convenience init<ID: Hashable & Sendable>(
        layout: NavigationLayout = .adaptive,
        selection: ID,
        sections: [RootSection]
    ) {
        self.init(layout: layout, sections: sections, selection: AnySectionID(selection))
    }

    /// Top-level sections rendered as tabs, a sidebar, or both (`.adaptive`). The first is selected.
    public convenience init(layout: NavigationLayout = .adaptive, sections: [RootSection]) {
        self.init(layout: layout, sections: sections, selection: nil)
    }

    init(layout: NavigationLayout, sections definitions: [RootSection], selection: AnySectionID?) {
        precondition(!definitions.isEmpty, "A NavigationStore needs at least one section.")
        self.layout = layout
        self.selectionIndex = 0
        self.sections = []
        // `sections` needs `self` for back-references, so build it after phase one.
        let nodes = definitions.map { SectionNode($0, store: self) }
        self.sections = nodes
        if let selection, let index = nodes.firstIndex(where: { $0.id == selection }) {
            selectionIndex = index
        }
    }

    // MARK: Public API

    /// A navigator that acts on whatever the user is currently looking at. Use it from code
    /// outside the view hierarchy; screens get a scoped navigator automatically.
    public var navigator: any Navigator { ActiveNavigator(store: self) }

    /// The selected section's id, if it is of type `ID`.
    public func selection<ID: Hashable & Sendable>(as _: ID.Type = ID.self) -> ID? {
        selectedSection.id.as(ID.self)
    }

    /// Opens a deep link. Returns `false` if no handler recognized it.
    @discardableResult
    public func open(_ url: URL) -> Bool {
        guard let steps = deepLinkHandler?(url) else {
            emit(.deepLinkFailed(url))
            return false
        }
        emit(.deepLinkOpened(url))
        Task { await navigate(steps) }
        return true
    }

    /// Navigates to `steps`, starting from the selected section's root. Open modals are
    /// dismissed first (respecting guards), and nested presentations are sequenced so each one
    /// appears only after its presenter is on screen.
    public func navigate(_ steps: [Step]) async {
        let discarded = modalsOnScreen().flatMap { $0.stack.guardHandlers() }
            + selectedSection.main.guardHandlers(for: selectedSection.main.path)
            + (selectedSection.detail.map { $0.guardHandlers(for: $0.path) } ?? [])
        guard await Self.pass(discarded) else {
            emit(.blockedByGuard)
            return
        }
        await dismissAll(ignoringGuards: true)
        selectedSection.resetToRoot()

        var cursor = selectedSection.main
        for step in steps {
            switch step {
            case let .select(id):
                guard let index = sections.firstIndex(where: { $0.id == id }) else {
                    emit(.unhandled(.select(id)))
                    continue
                }
                selectionIndex = index
                sections[index].resetToRoot()
                cursor = sections[index].main
                emit(.selected(id))
            case let .push(route):
                cursor.append(route)
                emit(.pushed(route))
            case let .show(route):
                if let detail = cursor.section?.detail, usesSplitLayout {
                    detail.reset(root: route)
                    cursor = detail
                    emit(.shown(route))
                } else {
                    cursor.append(route)
                    emit(.pushed(route))
                }
            case let .present(route, style):
                guard let modal = present(route, style: style, from: cursor, isFlow: false) else { continue }
                if isAttached { await modal.appeared.wait() }
                cursor = modal.stack
            }
        }
    }

    /// A stream of everything that happens in this store. Each call returns an independent stream.
    public func events() -> AsyncStream<NavigationEvent> {
        let (stream, continuation) = AsyncStream<NavigationEvent>.makeStream()
        let id = UUID()
        eventContinuations[id] = continuation
        continuation.onTermination = { [weak self] _ in
            Task { @MainActor in self?.eventContinuations[id] = nil }
        }
        return stream
    }

    // MARK: Derived state

    var selectedSection: SectionNode { sections[selectionIndex] }

    var effectiveLayout: NavigationLayout {
        if sections.count == 1, layout != .split { return .stack }
        if layout == .adaptive { return isRegularWidth ? .split : .tabs }
        return layout
    }

    var usesSplitLayout: Bool { effectiveLayout == .split }

    /// The stack the user is looking at right now.
    var activeStack: StackNode {
        let section = selectedSection
        if usesSplitLayout, let detail = section.detail, section.detailIsCustomized {
            return detail.topmost
        }
        return section.main.topmost
    }

    func modalsOnScreen() -> [ModalNode] {
        sections.flatMap { [$0.main.modal, $0.detail?.modal].compactMap { $0 } }
    }

    // MARK: Events

    func emit(_ event: NavigationEvent) {
        recentEvents.append(event)
        if recentEvents.count > 100 { recentEvents.removeFirst(recentEvents.count - 100) }
        eventHandlers.forEach { $0(event) }
        eventContinuations.values.forEach { $0.yield(event) }
        #if DEBUG
        if case .unhandled = event { print("[NavigationKit] \(event)") }
        #endif
    }

    // MARK: Size class

    func setRegularWidth(_ regular: Bool) {
        guard regular != isRegularWidth else { return }
        isRegularWidth = regular
        // Collapsing a split view: carry whatever the detail column showed onto the main stack
        // so the user keeps their place.
        guard !regular, layout == .adaptive else { return }
        for section in sections where section.detailIsCustomized {
            guard let detail = section.detail, let defaultDetail = section.defaultDetail else { continue }
            let carried = detail.entries.map { Entry(route: $0.route) }
            section.main.setPath(section.main.path + carried, emit: false)
            detail.reset(root: defaultDetail)
        }
    }
}

// MARK: - Handling actions

extension NavigationStore {
    @discardableResult
    func handle(_ action: NavigationAction, from origin: StackNode) -> Bool {
        if let route = action.targetRoute, needsAuthentication(for: route) {
            authenticate(route: route, from: origin) { [weak self] in
                _ = self?.handle(action, from: origin)
            }
            return true
        }

        let handled: Bool
        switch action {
        case let .push(route):
            handled = push(route, on: origin)
        case let .open(route):
            if let style = route.presentation {
                handled = present(route, style: style, from: origin, isFlow: false) != nil
            } else {
                handled = push(route, on: origin)
            }
        case .pop:
            handled = requestPop(on: origin, keeping: origin.path.count - 1)
        case .popToRoot:
            handled = requestPop(on: origin, keeping: 0)
        case let .popTo(route):
            if let index = origin.path.lastIndex(where: { $0.route == route }) {
                handled = requestPop(on: origin, keeping: index + 1)
            } else if origin.rootEntry.route == route {
                handled = requestPop(on: origin, keeping: 0)
            } else {
                handled = false
            }
        case let .present(route, style):
            handled = present(route, style: style ?? route.presentation ?? .sheet, from: origin, isFlow: false) != nil
        case let .show(route):
            handled = show(route, from: origin)
        case let .select(id):
            handled = select(id)
        case let .dismiss(result):
            handled = dismiss(from: origin, result: result)
        case .flow:
            Task { _ = await self.result(of: action, from: origin) }
            handled = true
        case let .finishFlow(result):
            handled = finishFlow(from: origin, result: result)
        case let .navigate(steps):
            Task { await self.navigate(steps) }
            handled = true
        case let .openURL(url):
            handled = open(url)
        }

        if !handled { emit(.unhandled(action)) }
        return handled
    }

    func result(of action: NavigationAction, from origin: StackNode) async -> (any Sendable)? {
        if let route = action.targetRoute, needsAuthentication(for: route) {
            guard await login(from: origin) else { return nil }
        }
        switch action {
        case let .present(route, style):
            return await presentForResult(route, style: style ?? route.presentation ?? .sheet, from: origin, isFlow: false)
        case let .flow(route, style):
            if let style = style ?? route.presentation {
                return await presentForResult(route, style: style, from: origin, isFlow: true)
            }
            return await withCheckedContinuation { continuation in
                let marker = FlowMarker(startIndex: origin.path.count, route: route, continuation: continuation)
                origin.flows.append(marker)
                origin.append(route)
                emit(.pushed(route))
            }
        default:
            handle(action, from: origin)
            return nil
        }
    }

    func dialog(_ dialog: Dialog, from origin: StackNode) async -> Dialog.Action.ID? {
        let target = origin.topmost
        target.dialog?.finish(nil)
        emit(.dialogShown(title: dialog.title))
        return await withCheckedContinuation { continuation in
            target.dialog = DialogRequest(dialog: dialog, continuation: continuation)
        }
    }

    func resolveDialog(on stack: StackNode, with action: Dialog.Action) {
        guard let request = stack.dialog else { return }
        action.perform()
        request.finish(action.id)
        stack.dialog = nil
    }

    // MARK: Stack

    private func push(_ route: AnyRoute, on stack: StackNode) -> Bool {
        let now = Date()
        if let last = stack.lastPush, last.route == route, now.timeIntervalSince(last.at) < 0.5,
           stack.path.last?.route == route {
            emit(.duplicatePushIgnored(route))
            return true
        }
        stack.lastPush = (route, now)
        stack.append(route)
        emit(.pushed(route))
        return true
    }

    /// Pops down to `count` screens above the root, asking guards of the screens being removed.
    private func requestPop(on stack: StackNode, keeping count: Int) -> Bool {
        guard count >= 0, count < stack.path.count else { return false }
        let removed = Array(stack.path[count...])
        let handlers = stack.guardHandlers(for: removed)
        let apply = { stack.setPath(Array(stack.path.prefix(count))) }
        if handlers.isEmpty {
            apply()
        } else {
            Task {
                if await Self.pass(handlers) { apply() } else { self.emit(.blockedByGuard) }
            }
        }
        return true
    }

    /// Called by the stack view when the user swipes back or taps a native back button.
    func userSetPath(_ path: [Entry], on stack: StackNode) {
        stack.setPath(path)
    }

    // MARK: Modals

    @discardableResult
    func present(_ route: AnyRoute, style: PresentationStyle, from origin: StackNode, isFlow: Bool) -> ModalNode? {
        let presenter = origin.topmost
        if style.kind == .window {
            if supportsMultipleWindows, let openWindow {
                openWindow(route)
                emit(.presented(route, style))
                return nil
            }
            return present(route, style: .sheet, from: presenter, isFlow: isFlow)
        }
        let stack = StackNode(root: route, store: self)
        let modal = ModalNode(style: style, stack: stack, presenter: presenter, isFlow: isFlow)
        presenter.modal = modal
        emit(.presented(route, style))
        return modal
    }

    private func presentForResult(_ route: AnyRoute, style: PresentationStyle, from origin: StackNode, isFlow: Bool) async -> (any Sendable)? {
        await withCheckedContinuation { continuation in
            if let modal = present(route, style: style, from: origin, isFlow: isFlow) {
                modal.awaitResult(continuation)
            } else {
                continuation.resume(returning: nil)
            }
        }
    }

    private func dismiss(from origin: StackNode, result: (any Sendable)?) -> Bool {
        guard let modal = nearestModal(containing: origin) else { return false }
        let handlers = modal.stack.guardHandlers()
        if handlers.isEmpty {
            closeModal(modal, result: result)
        } else {
            Task {
                if await Self.pass(handlers) { self.closeModal(modal, result: result) } else { self.emit(.blockedByGuard) }
            }
        }
        return true
    }

    /// Closes `modal` and everything above it, resolving every pending continuation exactly once.
    func closeModal(_ modal: ModalNode, result: (any Sendable)?) {
        guard let presenter = modal.presenter, presenter.modal === modal else { return }
        teardown(modal.stack)
        modal.finish(result)
        presenter.modal = nil
        if !isAttached || !modal.appeared.isSet { modal.disappeared.set() }
        emit(.dismissed(modal.stack.rootEntry.route))
    }

    /// Cancels everything pending inside `stack`: nested modals, flows and dialogs.
    private func teardown(_ stack: StackNode) {
        stack.flows.forEach { $0.finish(nil) }
        stack.flows = []
        stack.dialog?.finish(nil)
        stack.dialog = nil
        if let nested = stack.modal {
            teardown(nested.stack)
            nested.finish(nil)
            nested.disappeared.set()
        }
    }

    private func nearestModal(containing stack: StackNode) -> ModalNode? {
        stack.presentingModal
    }

    /// Dismisses every modal and waits until they are off screen.
    @discardableResult
    func dismissAll(ignoringGuards: Bool = false) async -> Bool {
        let modals = modalsOnScreen()
        guard !modals.isEmpty else { return true }
        if !ignoringGuards {
            guard await Self.pass(modals.flatMap { $0.stack.guardHandlers() }) else {
                emit(.blockedByGuard)
                return false
            }
        }
        modals.forEach { closeModal($0, result: nil) }
        if isAttached {
            for modal in modals { await modal.disappeared.wait() }
        }
        return true
    }

    // MARK: Sections

    private func select(_ id: AnySectionID) -> Bool {
        guard let index = sections.firstIndex(where: { $0.id == id }) else { return false }
        if modalsOnScreen().isEmpty {
            selectionIndex = index
            emit(.selected(id))
        } else {
            Task {
                guard await self.dismissAll() else { return }
                self.selectionIndex = index
                self.emit(.selected(id))
            }
        }
        return true
    }

    /// Called when the user taps a tab or sidebar item.
    func userSelect(_ index: Int) {
        guard sections.indices.contains(index), index != selectionIndex else { return }
        selectionIndex = index
        emit(.selected(sections[index].id))
    }

    private func show(_ route: AnyRoute, from origin: StackNode) -> Bool {
        if usesSplitLayout, let section = origin.section, let detail = section.detail {
            detail.reset(root: route)
            emit(.shown(route))
            return true
        }
        return push(route, on: origin)
    }

    // MARK: Flows

    private func finishFlow(from origin: StackNode, result: (any Sendable)?) -> Bool {
        var stack: StackNode? = origin
        while let current = stack {
            if let marker = current.flows.last(where: { $0.startIndex < current.path.count }) {
                if let modal = current.modal { closeModal(modal, result: nil) }
                current.flows.removeAll { $0 === marker }
                marker.finish(result)
                current.setPath(Array(current.path.prefix(marker.startIndex)))
                emit(.flowFinished(marker.route))
                return true
            }
            if let modal = current.presentingModal, modal.isFlow {
                emit(.flowFinished(modal.stack.rootEntry.route))
                closeModal(modal, result: result)
                return true
            }
            stack = current.presentingModal?.presenter
        }
        return false
    }

    // MARK: Auth

    private func needsAuthentication(for route: AnyRoute) -> Bool {
        guard route.requiresAuth, let authCheck, loginRoute != nil else { return false }
        return !authCheck()
    }

    private func authenticate(route: AnyRoute, from origin: StackNode, then proceed: @escaping @MainActor () -> Void) {
        emit(.authRequired(route))
        Task {
            if await self.login(from: origin) { proceed() }
        }
    }

    /// Presents the login route and waits. The login screen calls `nav.dismiss(returning: true)`.
    private func login(from origin: StackNode) async -> Bool {
        guard let loginRoute else { return false }
        let result = await presentForResult(loginRoute, style: loginRoute.presentation ?? .sheet, from: origin, isFlow: false)
        return (result as? Bool) == true && (authCheck?() ?? true)
    }

    // MARK: Helpers

    static func pass(_ handlers: [GuardHandler]) async -> Bool {
        for handler in handlers {
            guard await handler() else { return false }
        }
        return true
    }
}

// MARK: - Navigators

/// The navigator handed to a screen: scoped to the stack that screen lives on.
@MainActor
final class ScopedNavigator: Navigator {
    weak var stack: StackNode?

    init(stack: StackNode) {
        self.stack = stack
    }

    @discardableResult
    func perform(_ action: NavigationAction) -> Bool {
        guard let stack, let store = stack.store else { return false }
        return store.handle(action, from: stack)
    }

    func result(of action: NavigationAction) async -> (any Sendable)? {
        guard let stack, let store = stack.store else { return nil }
        return await store.result(of: action, from: stack)
    }

    func dialog(_ dialog: Dialog) async -> Dialog.Action.ID? {
        guard let stack, let store = stack.store else { return nil }
        return await store.dialog(dialog, from: stack)
    }
}

/// Resolves the visible stack at the moment each action is performed.
@MainActor
final class ActiveNavigator: Navigator {
    weak var store: NavigationStore?

    init(store: NavigationStore) {
        self.store = store
    }

    @discardableResult
    func perform(_ action: NavigationAction) -> Bool {
        guard let store else { return false }
        return store.handle(action, from: store.activeStack)
    }

    func result(of action: NavigationAction) async -> (any Sendable)? {
        guard let store else { return nil }
        return await store.result(of: action, from: store.activeStack)
    }

    func dialog(_ dialog: Dialog) async -> Dialog.Action.ID? {
        guard let store else { return nil }
        return await store.dialog(dialog, from: store.activeStack)
    }
}
