import NavigationKit
import SwiftUI

#if DEBUG
import NavigationKitDebug
#endif

struct ContentView: View {
    var body: some View {
        NavigationRoot(selection: AppTab.discover) {
            appSections
        }
        .layout(.adaptive)
        .routes(appModules)
        .deepLinks(AppLinks.self)
        .restoration(.sceneStorage("navigation"))
        .onNavigationEvent(NavigationAnalytics.track)
        #if DEBUG
        .navigationDebugger()
        #endif
        .withAppearanceSetting()
    }
}
