import Foundation
import Observation

@Observable
@MainActor
public final class Navigator {
    public internal(set) var root: AnyRoute
    public var path: [AnyRoute] = []
    public internal(set) var sheet: Navigator?
    public internal(set) var fullScreenCover: Navigator?

    enum Slot { case sheet, fullScreenCover }
    private weak var parent: Navigator?
    private let slot: Slot?

    public init<R: Hashable>(root: R) {
        self.root = AnyRoute(root); self.parent = nil; self.slot = nil
    }
    private init(root: AnyRoute, parent: Navigator, slot: Slot) {
        self.root = root; self.parent = parent; self.slot = slot
    }
    private func makeChild(root: AnyRoute, slot: Slot) -> Navigator {
        Navigator(root: root, parent: self, slot: slot)
    }

    public func push<R: Hashable>(_ route: R) { path.append(AnyRoute(route)) }
    public func pop()       { if !path.isEmpty { path.removeLast() } }
    public func popToRoot() { path.removeAll() }

    public func present<R: Hashable>(sheet route: R) {
        sheet = makeChild(root: AnyRoute(route), slot: .sheet)
    }
    public func present<R: Hashable>(fullScreenCover route: R) {
        fullScreenCover = makeChild(root: AnyRoute(route), slot: .fullScreenCover)
    }
    public func dismiss() {
        guard let parent, let slot else { return }
        switch slot {
        case .sheet:           parent.sheet = nil
        case .fullScreenCover: parent.fullScreenCover = nil
        }
    }

    /// Rebuild this context (and its modal subtree) from a snapshot.
    public func apply(_ state: NavigationState) {
        root = state.root
        path = state.path
        sheet = nil
        fullScreenCover = nil
        switch state.modal {
        case .sheet(let s):
            let child = makeChild(root: s.root, slot: .sheet)
            child.apply(s); sheet = child
        case .fullScreenCover(let s):
            let child = makeChild(root: s.root, slot: .fullScreenCover)
            child.apply(s); fullScreenCover = child
        case nil:
            break
        }
    }
}

extension Navigator: Identifiable {
    public nonisolated var id: ObjectIdentifier { ObjectIdentifier(self) }
}
