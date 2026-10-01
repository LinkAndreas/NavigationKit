import NavigationKit
import SwiftUI

public extension NavigationRoot {
    /// Adds a floating button (DEBUG builds only) that opens a live view of the navigation tree,
    /// the current path as steps, and the event log.
    func navigationDebugger() -> NavigationRoot {
        #if DEBUG
        accessory { store in NavigationDebuggerButton(store: store) }
        #else
        self
        #endif
    }
}

struct NavigationDebuggerButton: View {
    let store: NavigationStore
    @State private var isPresented = false
    /// Offset from the default bottom-trailing corner, so the button can be dragged out of the way.
    @State private var offset: CGSize = .zero
    @GestureState private var dragTranslation: CGSize = .zero

    var body: some View {
        GeometryReader { proxy in
            let button = Image(systemName: "point.3.connected.trianglepath.dotted")
                .font(.title3)
                .padding(12)
                .background(.thinMaterial, in: Circle())
                .contentShape(Circle())
            button
                .onTapGesture { isPresented = true }
                .offset(clamped(offset + dragTranslation, in: proxy.size))
                .gesture(
                    DragGesture(minimumDistance: 4)
                        .updating($dragTranslation) { value, state, _ in state = value.translation }
                        .onEnded { value in offset = clamped(offset + value.translation, in: proxy.size) }
                )
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }
        .sheet(isPresented: $isPresented) {
            NavigationDebuggerView(store: store)
        }
    }

    /// Keeps the button on screen. The offset is relative to the bottom-trailing corner, so it
    /// can only move up and to the leading side.
    private func clamped(_ offset: CGSize, in size: CGSize) -> CGSize {
        let buttonSize: CGFloat = 76 // icon, padding and outer padding
        return CGSize(
            width: min(0, max(offset.width, buttonSize - size.width)),
            height: min(0, max(offset.height, buttonSize - size.height))
        )
    }
}

private extension CGSize {
    static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
}

struct NavigationDebuggerView: View {
    let store: NavigationStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Current location") {
                    if store.currentSteps.isEmpty {
                        Text("Root").foregroundStyle(.secondary)
                    }
                    ForEach(Array(store.currentSteps.enumerated()), id: \.offset) { _, step in
                        Text(step.description).font(.callout.monospaced())
                    }
                }
                Section("Tree") {
                    ForEach(Array(store.snapshot.sections.enumerated()), id: \.offset) { index, section in
                        if let section {
                            DisclosureGroup("Section \(index)\(index == store.snapshot.selection ? " • selected" : "")") {
                                StackOutline(title: "main", stack: section.main)
                                if let detail = section.detail {
                                    StackOutline(title: "detail", stack: detail)
                                }
                            }
                        }
                    }
                }
                Section("Events") {
                    ForEach(Array(store.recentEvents.reversed().enumerated()), id: \.offset) { _, event in
                        Text(event.description).font(.caption.monospaced())
                    }
                }
            }
            .navigationTitle("Navigation")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct StackOutline: View {
    let title: String
    let stack: NavigationSnapshot.StackSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption.bold()).foregroundStyle(.secondary)
            ForEach(Array(([stack.root] + stack.path).enumerated()), id: \.offset) { depth, route in
                Text(String(repeating: "  ", count: depth) + "↳ " + route.description)
                    .font(.caption.monospaced())
            }
            if let modal = stack.modal {
                Text("presents (\(modal.style.description))").font(.caption2).foregroundStyle(.orange)
                StackOutline(title: "modal", stack: modal.stack)
                    .padding(.leading, 12)
            }
        }
    }
}
