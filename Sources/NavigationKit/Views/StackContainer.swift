import SwiftUI

/// A private SwiftUI View that renders a `StackNavigator`.
///
/// `StackContainer` binds a standard SwiftUI `NavigationStack` to the path state managed
/// by a `StackNavigator`. It also automatically attaches all standard modal presentation
/// modifiers (alerts, sheets, full-screen covers) driven by the navigator's state.
@MainActor
struct StackContainer: View {
    @Bindable var navigator: StackNavigator
    let routeBuilder: RouteBuilder

    var body: some View {
        NavigationStack(path: $navigator.path) {
            routeBuilder.view(for: navigator.root, navigator: navigator)
                .navigationDestination(for: AnyRoute.self) { route in
                    routeBuilder.view(for: route, navigator: navigator)
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
}
