import Foundation

/// A data-driven representation of a `NavigationSplitView` hierarchy.
///
/// `SplitState` allows you to define the sidebar, optional content, and detail columns of a
/// split navigator purely through data, mirroring how `StackState` and `TabsState` describe
/// their respective containers.
///
/// **Example Usage:**
/// ```swift
/// let state = SplitState(
///     sidebar: StackState(SidebarRoute()),
///     detail: StackState(DetailRoute())
/// )
/// ```
public struct SplitState: Equatable {
    /// The state of the sidebar column.
    public var sidebar: StackState?

    /// The state of the optional middle column (three-column layouts).
    public var content: StackState?

    /// The state of the detail column.
    public var detail: StackState?

    /// The desired column visibility. If `nil`, the current visibility remains unchanged.
    public var columnVisibility: SplitVisibility?

    /// The modal presentation (if any) currently displayed over the split view.
    public var modal: StackState.Modal? = nil

    /// Creates a new split navigation state.
    ///
    /// - Parameters:
    ///   - sidebar: The state of the sidebar column. Defaults to `nil` (unchanged).
    ///   - content: The state of the optional middle column. Defaults to `nil` (unchanged).
    ///   - detail: The state of the detail column. Defaults to `nil` (unchanged).
    ///   - columnVisibility: The desired column visibility. Defaults to `nil` (unchanged).
    ///   - modal: An optional modal presentation. Defaults to `nil`.
    public init(
        sidebar: StackState? = nil,
        content: StackState? = nil,
        detail: StackState? = nil,
        columnVisibility: SplitVisibility? = nil,
        modal: StackState.Modal? = nil
    ) {
        self.sidebar = sidebar
        self.content = content
        self.detail = detail
        self.columnVisibility = columnVisibility
        self.modal = modal
    }
}

public extension SplitState {
    /// Attaches a bottom sheet modal to this split state.
    ///
    /// - Parameter s: The `NavigationState` to display inside the sheet.
    /// - Returns: A new `SplitState` with the sheet modal attached.
    func presentingSheet(_ s: NavigationState) -> SplitState {
        var c = self
        c.modal = .sheet(s)
        return c
    }

    /// Wraps this split state inside a generic `NavigationState.split`.
    var asState: NavigationState { .split(self) }
}
