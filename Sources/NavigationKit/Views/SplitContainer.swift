import SwiftUI

/// A private SwiftUI View that renders a `SplitNavigator`.
///
/// `SplitContainer` binds a standard SwiftUI `NavigationSplitView` to the column state managed
/// by a `SplitNavigator`. Each column (sidebar, optional content, detail) wraps its own child
/// `NavigationContainer`, meaning each column can host its own independent navigation stack.
/// It also handles modal presentation.
@MainActor
struct SplitContainer: View {
    @Bindable var navigator: SplitNavigator
    let routeBuilder: RouteBuilder

    var body: some View {
        Group {
            if let content = navigator.content {
                NavigationSplitView(columnVisibility: columnVisibilityBinding) {
                    NavigationContainer(navigator: .stack(navigator.sidebar), routeBuilder: routeBuilder)
                } content: {
                    NavigationContainer(navigator: .stack(content), routeBuilder: routeBuilder)
                } detail: {
                    NavigationContainer(navigator: .stack(navigator.detail), routeBuilder: routeBuilder)
                }
            } else {
                NavigationSplitView(columnVisibility: columnVisibilityBinding) {
                    NavigationContainer(navigator: .stack(navigator.sidebar), routeBuilder: routeBuilder)
                } detail: {
                    NavigationContainer(navigator: .stack(navigator.detail), routeBuilder: routeBuilder)
                }
            }
        }
        .alert(spec: $navigator.modals.alert)
        .alert(error: $navigator.modals.error, retry: navigator.modals.errorRetry)
        .confirmationDialog(spec: $navigator.modals.confirmationDialog)
        .sheet(item: $navigator.modals.sheet) { modalNavigator in
            NavigationContainer(navigator: .stack(modalNavigator), routeBuilder: routeBuilder)
        }
        .fullScreenCoverOrSheet(item: $navigator.modals.fullScreenCover) { modalNavigator in
            NavigationContainer(navigator: .stack(modalNavigator), routeBuilder: routeBuilder)
        }
    }

    private var columnVisibilityBinding: Binding<NavigationSplitViewVisibility> {
        Binding(
            get: { navigator.columnVisibility.swiftUIValue },
            set: { navigator.columnVisibility = SplitVisibility(swiftUIValue: $0) }
        )
    }
}

extension SplitVisibility {
    var swiftUIValue: NavigationSplitViewVisibility {
        switch self {
        case .all: .all
        case .doubleColumn: .doubleColumn
        case .detailOnly: .detailOnly
        case .automatic: .automatic
        }
    }

    init(swiftUIValue: NavigationSplitViewVisibility) {
        switch swiftUIValue {
        case .all: self = .all
        case .doubleColumn: self = .doubleColumn
        case .detailOnly: self = .detailOnly
        default: self = .automatic
        }
    }
}
