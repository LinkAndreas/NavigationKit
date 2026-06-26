import Foundation

public struct AnyRoute: Hashable {
    let wrapped: AnyHashable
    let typeID: ObjectIdentifier
    public init<R: Hashable>(_ route: R) {
        self.wrapped = AnyHashable(route)
        self.typeID = ObjectIdentifier(R.self)
    }
    public static func == (l: Self, r: Self) -> Bool { l.wrapped == r.wrapped }
    public func hash(into h: inout Hasher) { h.combine(wrapped) }
}
