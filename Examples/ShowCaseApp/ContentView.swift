import Discover
import Foundation
import MyConf
import NavigationKit
import Schedule
import Speakers
import SwiftUI

#if DEBUG
import NavigationKitDebug
#endif

struct ContentView: View {
    var body: some View {
        NavigationRoot(selection: AppTab.discover) {
            RootSection(AppTab.discover, "discover", icon: "sparkles") { DiscoverRoute.discover }
            RootSection(AppTab.schedule, "schedule", icon: "calendar") {
                ScheduleRoute.list
            } detail: {
                ScheduleRoute.placeholder
            }
            RootSection(AppTab.myconf, "myconf", icon: "ticket") { MyConfRoute.overview }
            RootSection(AppTab.speakers, "speakers", icon: "person.2") { SpeakersRoute.overview }
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
