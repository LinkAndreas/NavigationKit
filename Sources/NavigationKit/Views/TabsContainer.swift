import SwiftUI

/// A private SwiftUI View that renders a `TabsNavigator`.
///
/// `TabsContainer` binds a standard SwiftUI `TabView` to the selected tab state managed
/// by a `TabsNavigator`. Each tab internally wraps its own child `NavigationContainer`, meaning
/// each tab can host its own independent navigation stack. It also handles modal presentation.
@MainActor struct TabsContainer: View {
    @Bindable var navigator: TabsNavigator
    let routeBuilder: RouteBuilder

    var body: some View {
        TabView(selection: $navigator.selection) {
            ForEach(navigator.tabs) { tab in
                Tab(LocalizedStringKey(tab.title), systemImage: tab.systemImage, value: tab.id) {
                    NavigationContainer(
                        navigator: .stack(tab.navigator),
                        routeBuilder: routeBuilder
                    )
                }
            }
        }
        .alert(spec: $navigator.modals.alert)
        .alert(error: $navigator.modals.error, retry: navigator.modals.errorRetry)
        .confirmationDialog(spec: $navigator.modals.confirmationDialog)
        .sheet(item: $navigator.modals.sheet) { modalNavigator in
            NavigationContainer(navigator: .stack(modalNavigator), routeBuilder: routeBuilder)
        }
        .fullScreenCover(item: $navigator.modals.fullScreenCover) { modalNavigator in
            NavigationContainer(navigator: .stack(modalNavigator), routeBuilder: routeBuilder)
        }
    }
}
