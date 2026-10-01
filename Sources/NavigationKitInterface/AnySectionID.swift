import Foundation

/// A type-erased identifier of a top-level section (a tab, or a sidebar item).
public struct AnySectionID: Hashable, Sendable, CustomStringConvertible {
    public let base: any Hashable & Sendable

    public init<ID: Hashable & Sendable>(_ id: ID) {
        if let erased = id as? AnySectionID {
            self = erased
        } else {
            base = id
        }
    }

    /// The wrapped identifier if it is of type `ID`.
    public func `as`<ID: Hashable & Sendable>(_: ID.Type = ID.self) -> ID? { base as? ID }

    public static func == (lhs: AnySectionID, rhs: AnySectionID) -> Bool {
        AnyHashable(lhs.base) == AnyHashable(rhs.base)
    }

    public func hash(into hasher: inout Hasher) { hasher.combine(AnyHashable(base)) }

    public var description: String { "\(base)" }
}
