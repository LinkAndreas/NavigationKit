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

    var body: some View {
        Button {
            isPresented = true
        } label: {
            Image(systemName: "point.3.connected.trianglepath.dotted")
                .font(.title3)
                .padding(12)
                .background(.thinMaterial, in: Circle())
        }
        .buttonStyle(.plain)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .sheet(isPresented: $isPresented) {
            NavigationDebuggerView(store: store)
        }
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
