import Discover
import MyConf
import NavigationKit
import Schedule
import Speakers

/// The app's top-level sections. Their ids are what `nav.select(_:)` and deep links refer to.
public enum AppTab: Hashable, Sendable {
    case discover
    case schedule
    case myconf
    case speakers
}

/// Declared once; rendered as a tab bar on iPhone and as a sidebar with detail on iPad,
/// switching live when the window's width changes.
@RootSectionsBuilder
var appSections: [RootSection] {
    RootSection(AppTab.discover, "discover", icon: "sparkles") { DiscoverRoute.discover }
    RootSection(AppTab.schedule, "schedule", icon: "calendar") {
        ScheduleRoute.list
    } detail: {
        ScheduleRoute.placeholder
    }
    RootSection(AppTab.myconf, "myconf", icon: "ticket") { MyConfRoute.overview }
    RootSection(AppTab.speakers, "speakers", icon: "person.2") { SpeakersRoute.overview }
}
