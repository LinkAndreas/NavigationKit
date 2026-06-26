import Foundation

/// URL → snapshot. The root registers handlers; mount strategy lives in them.
@MainActor
public struct DeepLinkResolver {
    private var handlers: [(URL) -> NavigationState?] = []
    public init() {}
    public mutating func register(_ h: @escaping (URL) -> NavigationState?) { handlers.append(h) }
    public func resolve(_ url: URL) -> NavigationState? {
        for h in handlers { if let s = h(url) { return s } }
        return nil
    }
}
