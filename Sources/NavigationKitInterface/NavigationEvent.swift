import Foundation

/// Everything that happens in the navigation tree, as a single stream. Use it for analytics,
/// logging, and debugging instead of sprinkling tracking calls through screens.
public enum NavigationEvent: Sendable, CustomStringConvertible {
    case pushed(AnyRoute)
    case popped([AnyRoute])
    case presented(AnyRoute, PresentationStyle)
    case dismissed(AnyRoute)
    case selected(AnySectionID)
    case shown(AnyRoute)
    case flowFinished(AnyRoute)
    case dialogShown(title: String)
    case deepLinkOpened(URL)
    case deepLinkFailed(URL)
    case authRequired(AnyRoute)
    case blockedByGuard
    case duplicatePushIgnored(AnyRoute)
    case unhandled(NavigationAction)
    case restored

    public var description: String {
        switch self {
        case let .pushed(r): "pushed \(r)"
        case let .popped(rs): "popped \(rs)"
        case let .presented(r, s): "presented \(r) as \(s)"
        case let .dismissed(r): "dismissed \(r)"
        case let .selected(id): "selected \(id)"
        case let .shown(r): "shown \(r)"
        case let .flowFinished(r): "flow finished \(r)"
        case let .dialogShown(title): "dialog \"\(title)\""
        case let .deepLinkOpened(url): "deep link \(url)"
        case let .deepLinkFailed(url): "deep link failed \(url)"
        case let .authRequired(r): "auth required for \(r)"
        case .blockedByGuard: "blocked by guard"
        case let .duplicatePushIgnored(r): "ignored duplicate push \(r)"
        case let .unhandled(a): "unhandled \(a)"
        case .restored: "restored"
        }
    }
}
