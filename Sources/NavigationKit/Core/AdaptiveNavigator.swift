import Foundation
import Observation

/// The layout an ``AdaptiveNavigator`` shows, chosen from the width its window has.
public enum AdaptiveLayout: Hashable, Sendable {
    /// Too narrow for columns (a compact horizontal size class): the tab bar.
    case compact

    /// Room for columns (a regular horizontal size class): the split view.
    case regular
}

/// A navigator that shows a tab bar when its window is narrow and a split view when it is
/// wide, switching whenever the window changes width — on a foldable iPhone being unfolded,
/// an iPad app resized in Split View or Stage Manager, or a large iPhone rotated to landscape.
///
/// The tab bar and the split view each keep their own navigator, so each keeps its own state
/// while the other is on screen. Only one is shown at a time, and switching rebuilds its view
/// hierarchy — anything presented by a tab or a column (and not by this navigator) is
/// dismissed. Present modals that must survive a resize, such as a running task, from the
/// adaptive navigator itself: its sheet, full-screen cover, and alerts sit above both layouts.
///
/// The two layouts don't share routes, so what the user was looking at doesn't carry over by
/// itself. Set ``onLayoutChange`` to move it across (select the matching tab, open the same
/// detail).
///
/// **Example Usage:**
/// ```swift
/// let navigator = AdaptiveNavigator(
///     compact: TabsNavigator(tabs: tabs),
///     regular: SplitNavigator(sidebar: sidebar, content: content, detail: detail)
/// )
/// navigator.onLayoutChange = { old, new in
///     // Carry the selection over from the layout that was showing.
/// }
/// ```
@Observable
@MainActor
public final class AdaptiveNavigator: ModalPresenter, Identifiable {
    /// The navigator driving the tab bar shown in a narrow window.
    public let compact: TabsNavigator

    /// The navigator driving the split view shown in a wide window.
    public let regular: SplitNavigator

    /// The layout on screen, or `nil` until the navigator is first shown and knows its
    /// window's width.
    public private(set) var layout: AdaptiveLayout?

    /// The composed modal-presentation state (sheet, full screen cover, alert, etc.), shown
    /// over both layouts.
    public var modals = ModalBox()

    /// Called when ``layout`` changes: once when the navigator is first shown (with `nil` as the
    /// old layout), then on every switch. Called before the new layout's view is shown, so
    /// state moved across in it appears with it.
    @ObservationIgnored public var onLayoutChange: ((_ old: AdaptiveLayout?, _ new: AdaptiveLayout) -> Void)?

    /// Creates an adaptive navigator switching between a tab bar and a split view.
    ///
    /// - Parameters:
    ///   - compact: The navigator driving the tab bar shown in a narrow window.
    ///   - regular: The navigator driving the split view shown in a wide window.
    public init(compact: TabsNavigator, regular: SplitNavigator) {
        self.compact = compact
        self.regular = regular
    }

    /// Both layouts' navigators, so that modal dismissals cascade into whichever is hidden too.
    public var presentableChildren: [any ModalPresenter] {
        [compact, regular]
    }

    /// The tab bar's navigator while it is on screen; `nil` in a wide window or before the
    /// navigator is first shown.
    public var activeTabs: TabsNavigator? {
        layout == .compact ? compact : nil
    }

    /// The split view's navigator while it is on screen; `nil` in a narrow window or before
    /// the navigator is first shown.
    public var activeSplit: SplitNavigator? {
        layout == .regular ? regular : nil
    }

    /// Records the layout on screen. Called by the container view as its width changes.
    func updateLayout(_ newLayout: AdaptiveLayout) {
        guard newLayout != layout else { return }
        let oldLayout = layout
        layout = newLayout
        onLayoutChange?(oldLayout, newLayout)
    }
}
