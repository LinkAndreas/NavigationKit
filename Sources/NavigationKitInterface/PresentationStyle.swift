import Foundation

/// How a route is presented modally. Platform-neutral: each style maps to the closest native
/// presentation (for example, `.cover` is a full-screen cover on iOS and a sheet on macOS).
public struct PresentationStyle: Hashable, Codable, Sendable, CustomStringConvertible {
    public enum Kind: String, Hashable, Codable, Sendable {
        case sheet, cover, popover, inspector, window
    }

    public var kind: Kind
    public var detents: [Detent]
    /// The source a `.cover` zooms out of. Mark the source view with `.navigationZoomSource(_:)`.
    public var zoomSourceID: String?

    public init(kind: Kind, detents: [Detent] = [], zoomSourceID: String? = nil) {
        self.kind = kind
        self.detents = detents
        self.zoomSourceID = zoomSourceID
    }

    public static let sheet = PresentationStyle(kind: .sheet)
    public static func sheet(detents: [Detent]) -> PresentationStyle { .init(kind: .sheet, detents: detents) }

    public static let cover = PresentationStyle(kind: .cover)
    public static func cover(zoomFrom sourceID: String) -> PresentationStyle {
        .init(kind: .cover, zoomSourceID: sourceID)
    }

    public static let popover = PresentationStyle(kind: .popover)
    public static let inspector = PresentationStyle(kind: .inspector)
    /// A new window on platforms that support multiple windows; a sheet everywhere else.
    /// Requires a `RouteWindows` scene in your `App`.
    public static let window = PresentationStyle(kind: .window)

    public var description: String {
        var parts = [kind.rawValue]
        if !detents.isEmpty { parts.append("detents: \(detents)") }
        if let zoomSourceID { parts.append("zoomFrom: \(zoomSourceID)") }
        return parts.joined(separator: " ")
    }
}

/// A resting height for a sheet.
public enum Detent: Hashable, Codable, Sendable {
    case medium
    case large
    case fraction(Double)
    case height(Double)
}
