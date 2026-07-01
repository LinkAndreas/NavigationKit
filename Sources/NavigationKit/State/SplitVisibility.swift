import Foundation

/// A data-driven representation of `NavigationSplitViewVisibility`.
///
/// Kept as a plain, `Foundation`-only enum (instead of depending on SwiftUI directly) so that
/// `SplitState` remains a lightweight value type usable for deep link parsing and snapshotting.
/// `SplitContainer` maps this to the real SwiftUI type when rendering.
public enum SplitVisibility: Equatable, Sendable {
    case all
    case doubleColumn
    case detailOnly
    case automatic
}
