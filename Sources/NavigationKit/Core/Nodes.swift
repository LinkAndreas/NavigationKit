import Foundation
import Observation

/// A route on a stack, with an identity so the same route can appear twice and guards can be
/// attached to one specific screen.
struct Entry: Hashable, Identifiable {
    let id = UUID()
    let route: AnyRoute
}

/// A one-shot signal that can be awaited. Waiting never hangs forever: after `timeout` the
/// waiter gives up, so headless use and unusual presentation paths can't deadlock navigation.
@MainActor
final class Signal {
    private(set) var isSet = false
    private var waiters: [CheckedContinuation<Void, Never>] = []

    func set() {
        guard !isSet else { return }
        isSet = true
        let pending = waiters
        waiters = []
        pending.forEach { $0.resume() }
    }

    func wait(timeout: Duration = .seconds(1)) async {
        if isSet { return }
        await withCheckedContinuation { continuation in
            waiters.append(continuation)
            Task { @MainActor [weak self] in
                try? await Task.sleep(for: timeout)
                self?.set()
            }
        }
    }
}

typealias GuardHandler = @MainActor () async -> Bool

/// A pushed flow waiting for `finishFlow`.
@MainActor
final class FlowMarker {
    let startIndex: Int
    let route: AnyRoute
    private var continuation: CheckedContinuation<(any Sendable)?, Never>?

    init(startIndex: Int, route: AnyRoute, continuation: CheckedContinuation<(any Sendable)?, Never>) {
        self.startIndex = startIndex
        self.route = route
        self.continuation = continuation
    }

    func finish(_ result: (any Sendable)?) {
        continuation?.resume(returning: result)
        continuation = nil
    }
}

/// A dialog waiting for the user's choice.
@MainActor
final class DialogRequest: Identifiable {
    let dialog: Dialog
    private var continuation: CheckedContinuation<Dialog.Action.ID?, Never>?
    var id: UUID { dialog.id }

    init(dialog: Dialog, continuation: CheckedContinuation<Dialog.Action.ID?, Never>) {
        self.dialog = dialog
        self.continuation = continuation
    }

    var isPending: Bool { continuation != nil }

    func finish(_ actionID: Dialog.Action.ID?) {
        continuation?.resume(returning: actionID)
        continuation = nil
    }
}

/// One navigation stack: a root, a path, and at most one modal and one dialog on top.
@Observable @MainActor
final class StackNode: Identifiable {
    let id = UUID()
    private(set) var rootEntry: Entry
    private(set) var path: [Entry] = []
    var modal: ModalNode?
    var dialog: DialogRequest?

    @ObservationIgnored weak var store: NavigationStore?
    /// Set when this stack is a column of a top-level section.
    @ObservationIgnored weak var section: SectionNode?
    /// Set when this stack is the content of a modal.
    @ObservationIgnored weak var presentingModal: ModalNode?
    @ObservationIgnored var guards: [Entry.ID: GuardHandler] = [:]
    @ObservationIgnored var flows: [FlowMarker] = []
    @ObservationIgnored var lastPush: (route: AnyRoute, at: Date)?

    init(root: AnyRoute, store: NavigationStore?) {
        rootEntry = Entry(route: root)
        self.store = store
    }

    var entries: [Entry] { [rootEntry] + path }

    /// Whether this stack is a column of a `NavigationSplitView` right now.
    var isSplitColumn: Bool { section != nil && store?.usesSplitLayout == true }

    /// The stack the user is looking at when starting from this one: follows presented modals.
    var topmost: StackNode {
        var stack = self
        while let modal = stack.modal { stack = modal.stack }
        return stack
    }

    /// The single place the path changes. Cancels flows that were popped out of, drops guards of
    /// removed screens, and reports what changed.
    func setPath(_ newPath: [Entry], emit: Bool = true) {
        let keptIDs = Set(newPath.map(\.id))
        let oldIDs = Set(path.map(\.id))
        let removed = path.filter { !keptIDs.contains($0.id) }
        let added = newPath.filter { !oldIDs.contains($0.id) }

        for flow in flows where flow.startIndex >= newPath.count {
            flow.finish(nil)
        }
        flows.removeAll { $0.startIndex >= newPath.count }
        removed.forEach { guards[$0.id] = nil }

        path = newPath

        guard emit else { return }
        if !removed.isEmpty { store?.emit(.popped(removed.map(\.route))) }
        added.forEach { store?.emit(.pushed($0.route)) }
    }

    func append(_ route: AnyRoute) {
        setPath(path + [Entry(route: route)], emit: false)
    }

    /// Replaces the whole stack (used for split-view detail columns and deep links).
    func reset(root: AnyRoute? = nil) {
        if let root, root != rootEntry.route {
            guards[rootEntry.id] = nil
            rootEntry = Entry(route: root)
        }
        setPath([], emit: false)
    }

    /// Guard handlers for `entries` (default: the whole stack) and everything presented above.
    func guardHandlers(for entries: [Entry]? = nil) -> [GuardHandler] {
        let own = (entries ?? self.entries).reversed().compactMap { guards[$0.id] }
        let presented = modal.map { $0.stack.guardHandlers() } ?? []
        return presented + own
    }

    var hasActiveGuard: Bool { !guardHandlers().isEmpty }
}

/// A modal presentation: its style, the stack inside it, and whoever awaits its result.
@Observable @MainActor
final class ModalNode: Identifiable {
    let id = UUID()
    let style: PresentationStyle
    let stack: StackNode
    let isFlow: Bool

    @ObservationIgnored weak var presenter: StackNode?
    @ObservationIgnored private var continuation: CheckedContinuation<(any Sendable)?, Never>?
    let appeared = Signal()
    let disappeared = Signal()

    init(style: PresentationStyle, stack: StackNode, presenter: StackNode, isFlow: Bool) {
        self.style = style
        self.stack = stack
        self.presenter = presenter
        self.isFlow = isFlow
        stack.presentingModal = self
    }

    /// The presentation actually used on this platform.
    var effectiveKind: PresentationStyle.Kind {
        #if os(macOS)
        style.kind == .cover ? .sheet : style.kind
        #else
        style.kind
        #endif
    }

    func awaitResult(_ continuation: CheckedContinuation<(any Sendable)?, Never>) {
        self.continuation = continuation
    }

    func finish(_ result: (any Sendable)?) {
        continuation?.resume(returning: result)
        continuation = nil
    }
}

/// A top-level section: a tab on iPhone, a sidebar item on iPad and Mac.
@Observable @MainActor
final class SectionNode: Identifiable {
    let id: AnySectionID
    let title: LocalizedStringResource
    let icon: String?
    let main: StackNode
    let detail: StackNode?
    let defaultDetail: AnyRoute?

    init(_ definition: RootSection, store: NavigationStore) {
        id = definition.id
        title = definition.title
        icon = definition.icon
        main = StackNode(root: definition.root, store: store)
        detail = definition.detail.map { StackNode(root: $0, store: store) }
        defaultDetail = definition.detail
        main.section = self
        detail?.section = self
    }

    /// Whether the detail column shows something other than its placeholder.
    var detailIsCustomized: Bool {
        guard let detail else { return false }
        return detail.rootEntry.route != defaultDetail || !detail.path.isEmpty
    }

    func resetToRoot() {
        main.reset()
        if let defaultDetail { detail?.reset(root: defaultDetail) }
    }
}
