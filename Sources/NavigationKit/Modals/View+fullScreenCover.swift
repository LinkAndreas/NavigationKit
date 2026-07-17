import SwiftUI

extension View {
    /// Presents `item` as a full-screen cover, falling back to a sheet on macOS.
    ///
    /// macOS has no full-screen cover; a sheet is its closest native equivalent. Keeping that
    /// substitution here — rather than making `present(fullScreenCover:)` unavailable on macOS —
    /// means `ModalBox.fullScreenCover` and `StackState.Modal.fullScreenCover` stay identical on
    /// every platform, so navigation state and deep links round-trip across platforms unchanged.
    @ViewBuilder
    func fullScreenCoverOrSheet<Item: Identifiable, Content: View>(
        item: Binding<Item?>,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View {
        #if os(macOS)
        sheet(item: item, content: content)
        #else
        fullScreenCover(item: item, content: content)
        #endif
    }
}
