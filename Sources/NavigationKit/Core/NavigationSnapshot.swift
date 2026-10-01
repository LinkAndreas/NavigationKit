import Foundation

/// The complete navigation state of a ``NavigationStore`` as `Codable` data — for state
/// restoration, Handoff, or debugging.
///
/// Decoding is *lossy by design*: a route that no longer decodes (renamed type, removed case)
/// truncates its stack at that point instead of failing the whole snapshot, so app updates
/// never strand users on a broken restore.
public struct NavigationSnapshot: Codable, Equatable, Sendable {
    public static let currentVersion = 1

    public var version: Int
    public var selection: Int
    /// One entry per section, `nil` where a section couldn't be decoded.
    public var sections: [SectionSnapshot?]

    public init(selection: Int, sections: [SectionSnapshot?]) {
        self.version = Self.currentVersion
        self.selection = selection
        self.sections = sections
    }

    public struct SectionSnapshot: Codable, Equatable, Sendable {
        public var main: StackSnapshot
        public var detail: StackSnapshot?
    }

    public struct StackSnapshot: Codable, Equatable, Sendable {
        public var root: AnyRoute
        public var path: [AnyRoute]
        // An array breaks the value-type recursion StackSnapshot → ModalSnapshot → StackSnapshot.
        private var modals: [ModalSnapshot]

        public var modal: ModalSnapshot? {
            get { modals.first }
            set { modals = newValue.map { [$0] } ?? [] }
        }

        public init(root: AnyRoute, path: [AnyRoute] = [], modal: ModalSnapshot? = nil) {
            self.root = root
            self.path = path
            self.modals = modal.map { [$0] } ?? []
        }

        private enum CodingKeys: String, CodingKey { case root, path, modals }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            root = try container.decode(AnyRoute.self, forKey: .root)
            let lossyPath = (try? container.decode([Lossy<AnyRoute>].self, forKey: .path)) ?? []
            path = Array(lossyPath.prefix { $0.value != nil }.compactMap(\.value))
            let lossyModals = (try? container.decode([Lossy<ModalSnapshot>].self, forKey: .modals)) ?? []
            modals = lossyModals.first?.value.map { [$0] } ?? []
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(root, forKey: .root)
            try container.encode(path, forKey: .path)
            try container.encode(modals, forKey: .modals)
        }
    }

    public struct ModalSnapshot: Codable, Equatable, Sendable {
        public var style: PresentationStyle
        public var stack: StackSnapshot
    }

    private enum CodingKeys: String, CodingKey { case version, selection, sections }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decodeIfPresent(Int.self, forKey: .version) ?? Self.currentVersion
        selection = try container.decode(Int.self, forKey: .selection)
        sections = try container.decode([Lossy<SectionSnapshot>].self, forKey: .sections).map(\.value)
    }
}

/// Decodes `T` or yields `nil` — but always consumes its element, so decoding an array of these
/// keeps going past a bad entry.
struct Lossy<T: Decodable>: Decodable {
    let value: T?

    init(from decoder: any Decoder) throws {
        value = try? T(from: decoder)
    }
}

// MARK: - Store ↔ snapshot

extension NavigationStore {
    /// The current state as data.
    public var snapshot: NavigationSnapshot {
        NavigationSnapshot(
            selection: selectionIndex,
            sections: sections.map { section in
                NavigationSnapshot.SectionSnapshot(main: snapshot(of: section.main), detail: section.detail.map(snapshot(of:)))
            }
        )
    }

    private func snapshot(of stack: StackNode) -> NavigationSnapshot.StackSnapshot {
        NavigationSnapshot.StackSnapshot(
            root: stack.rootEntry.route,
            path: stack.path.map(\.route),
            modal: stack.modal.map { .init(style: $0.style, stack: snapshot(of: $0.stack)) }
        )
    }

    /// Restores `snapshot`. Sections are matched by position; sections or routes that don't
    /// match the current app are skipped. Modals are re-presented one after another, and only
    /// for the selected section.
    public func restore(_ snapshot: NavigationSnapshot) async {
        await dismissAll(ignoringGuards: true)
        for (section, saved) in zip(sections, snapshot.sections) {
            guard let saved else { continue }
            restore(saved.main, into: section.main)
            if let detail = section.detail, let savedDetail = saved.detail {
                restore(savedDetail, into: detail)
            }
        }
        if sections.indices.contains(snapshot.selection) {
            selectionIndex = snapshot.selection
        }
        if let saved = snapshot.sections[safe: selectionIndex] ?? nil {
            if isAttached, saved.main.modal != nil || saved.detail?.modal != nil {
                await sceneIsActive.wait()
            }
            await presentModals(saved.main.modal, from: selectedSection.main)
            if let detail = selectedSection.detail {
                await presentModals(saved.detail?.modal, from: detail)
            }
        }
        emit(.restored)
    }

    private func restore(_ saved: NavigationSnapshot.StackSnapshot, into stack: StackNode) {
        // Section roots come from code, not from disk: only restore the path if the root matches,
        // except for detail columns whose root is user-driven.
        if stack.section?.detail === stack {
            stack.reset(root: saved.root)
        } else if stack.rootEntry.route != saved.root {
            return
        }
        stack.setPath(saved.path.map { Entry(route: $0) }, emit: false)
    }

    private func presentModals(_ saved: NavigationSnapshot.ModalSnapshot?, from presenter: StackNode) async {
        guard let saved else { return }
        guard let modal = present(saved.stack.root, style: saved.style, from: presenter, isFlow: false) else { return }
        modal.stack.setPath(saved.stack.path.map { Entry(route: $0) }, emit: false)
        if isAttached { await modal.appeared.wait() }
        await presentModals(saved.stack.modal, from: modal.stack)
    }

    /// Where the user is, as layout-independent steps — the same language as
    /// `Navigator.navigate(_:)` and deep links. Handy for tests:
    /// `#expect(store.currentSteps == [.select(AppTab.schedule), .push(ScheduleRoute.session(id: "42"))])`.
    public var currentSteps: [Step] {
        var steps: [Step] = []
        let section = selectedSection
        if sections.count > 1 { steps.append(.select(section: section.id)) }
        steps += section.main.path.map { .push(route: $0.route) }
        var deepest = section.main
        if let detail = section.detail, section.detailIsCustomized {
            steps.append(.show(route: detail.rootEntry.route))
            steps += detail.path.map { .push(route: $0.route) }
            if detail.modal != nil || section.main.modal == nil { deepest = detail }
        }
        var modal = deepest.modal
        while let current = modal {
            steps.append(.present(route: current.stack.rootEntry.route, style: current.style))
            steps += current.stack.path.map { .push(route: $0.route) }
            modal = current.stack.modal
        }
        return steps
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
