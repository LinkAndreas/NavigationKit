import Foundation

/// A type-erased ``Route``. You rarely create one yourself; it appears in actions, events and
/// snapshots so heterogeneous routes can live side by side.
public struct AnyRoute: Hashable, Sendable, Codable, CustomStringConvertible {
    public let base: any Route

    public init<R: Route>(_ route: R) {
        base = route
        RouteTypes.register(R.self)
    }

    /// The wrapped route if it is of type `R`.
    public func `as`<R: Route>(_: R.Type = R.self) -> R? { base as? R }

    public var presentation: PresentationStyle? { base.presentation }
    public var requiresAuth: Bool { base.requiresAuth }
    public var hidesTabBar: Bool { base.hidesTabBar }

    public static func == (lhs: AnyRoute, rhs: AnyRoute) -> Bool {
        AnyHashable(lhs.base) == AnyHashable(rhs.base)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(AnyHashable(base))
    }

    public var description: String { "\(type(of: base)).\(base)" }

    // MARK: Codable

    private enum CodingKeys: String, CodingKey { case type, value }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type(of: base).routeKey, forKey: .type)
        try base.encode(to: container.superEncoder(forKey: .value))
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = try container.decode(String.self, forKey: .type)
        guard let decode = RouteTypes.decoder(for: key) else {
            throw DecodingError.dataCorruptedError(
                forKey: .type, in: container,
                debugDescription: "Unknown route type '\(key)'. Register it via RouteTypes.register(_:) or a RouteModule."
            )
        }
        self = try decode(try container.superDecoder(forKey: .value))
    }
}

/// The registry of route types that can be decoded from persisted state.
///
/// Every route type is registered automatically the first time it is wrapped in an
/// ``AnyRoute`` — i.e. whenever it is pushed, presented or declared as a section root.
/// Register types explicitly (or list them in `RouteModule`) when state may be restored
/// before a type has been used in the current process.
public enum RouteTypes {
    private static let lock = NSLock()
    nonisolated(unsafe) private static var decoders: [String: @Sendable (any Decoder) throws -> AnyRoute] = [:]

    public static func register<R: Route>(_: R.Type) {
        lock.withLock {
            guard decoders[R.routeKey] == nil else { return }
            decoders[R.routeKey] = { decoder in AnyRoute(try R(from: decoder)) }
        }
    }

    static func decoder(for key: String) -> (@Sendable (any Decoder) throws -> AnyRoute)? {
        lock.withLock { decoders[key] }
    }
}
