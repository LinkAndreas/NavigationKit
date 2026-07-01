import NavigationKit

import SwiftUI
import UIKit

struct ContentView: View {
    var body: some View {
        WithContext {
            AppContext()
        } content: { context in
            NavigationContainer(
                navigator: context.navigator,
                routeBuilder: context.routeBuilder
            )
            .withAppearanceSetting()
            .withOptionalNavigationGraphDebugger(navigator: context.navigator)
            .onOpenURL { url in
                if let navigationState = context.deeplinkResolver.resolve(url) {
                    applyDeepLink(navigationState, to: context.navigator)
                }
            }
        }
    }
}
