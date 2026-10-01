import SwiftUI

/// Renders the store's sections in the effective layout and keeps the store informed about
/// the window's width.
struct RootLayoutView: View {
    let store: NavigationStore
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var columnVisibility: NavigationSplitViewVisibility = .automatic

    private var isRegularWidth: Bool {
        #if os(macOS)
        true
        #else
        sizeClass == .regular
        #endif
    }

    var body: some View {
        content
            .onChange(of: isRegularWidth, initial: true) { _, regular in
                store.setRegularWidth(regular)
            }
    }

    @ViewBuilder
    private var content: some View {
        // Read the size class here so a change re-evaluates `effectiveLayout`.
        let _ = isRegularWidth
        switch store.effectiveLayout {
        case .stack, .adaptive:
            StackView(stack: store.selectedSection.main)
                .id(store.selectedSection.id)
        case .tabs:
            tabs
        case .split:
            split
        }
    }

    private var tabs: some View {
        TabView(selection: Binding(get: { store.selectionIndex }, set: { store.userSelect($0) })) {
            ForEach(Array(store.sections.enumerated()), id: \.element.id) { index, section in
                Tab(value: index) {
                    StackView(stack: section.main)
                } label: {
                    SectionLabel(section: section)
                }
            }
        }
    }

    private var split: some View {
        let section = store.selectedSection
        return splitView(section)
            .modifier(InspectorPresentationModifier(stacks: [section.main] + [section.detail].compactMap { $0 }))
    }

    @ViewBuilder
    private func splitView(_ section: SectionNode) -> some View {
        if let detail = section.detail {
            NavigationSplitView(columnVisibility: $columnVisibility) {
                sidebar
            } content: {
                StackView(stack: section.main).id(section.id)
            } detail: {
                StackView(stack: detail).id(detail.id)
            }
        } else {
            NavigationSplitView(columnVisibility: $columnVisibility) {
                sidebar
            } detail: {
                StackView(stack: section.main).id(section.id)
            }
        }
    }

    private var sidebar: some View {
        List(selection: Binding<Int?>(
            get: { store.selectionIndex },
            set: { if let index = $0 { store.userSelect(index) } }
        )) {
            ForEach(Array(store.sections.enumerated()), id: \.element.id) { index, section in
                SectionLabel(section: section)
                    .tag(index)
            }
        }
    }
}

struct SectionLabel: View {
    let section: SectionNode

    var body: some View {
        Label {
            Text(section.title)
        } icon: {
            Image(systemName: section.icon ?? "circle")
        }
    }
}
