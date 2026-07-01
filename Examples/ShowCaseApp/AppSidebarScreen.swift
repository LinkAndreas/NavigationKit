import NavigationKit
import SwiftUI

/// The iPad sidebar: a native `List(selection:)` over `appTabItems` that drives the
/// split navigator's detail column directly, mirroring the tab bar's role on iPhone.
struct AppSidebarScreen: View {
    let items: [AppTabItem]
    let splitNavigator: SplitNavigator

    var body: some View {
        List(selection: selection) {
            ForEach(items) { item in
                Label(item.title, systemImage: item.systemImage)
                    .tag(item.id)
            }
        }
        .navigationTitle("ShowCase")
    }

    private var selection: Binding<AppTab?> {
        Binding(
            get: {
                items.first { $0.rootRoute == splitNavigator.detail.root }?.id
            },
            set: { newValue in
                guard let newValue, let item = items.first(where: { $0.id == newValue }) else { return }
                item.openInDetail(splitNavigator)
            }
        )
    }
}
