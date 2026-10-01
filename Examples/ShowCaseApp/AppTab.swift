import Foundation

/// The app's top-level sections. Their ids are what `nav.select(_:)` and deep links refer to.
nonisolated public enum AppTab: Hashable, Sendable {
    case discover
    case schedule
    case myconf
    case speakers
}
