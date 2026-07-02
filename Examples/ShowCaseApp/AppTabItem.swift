import Discover
import MyConf
import NavigationKit
import Schedule
import Speakers

/// Metadata for one top-level feature of the app.
///
/// Used to build both the iPhone tab bar (`TabsNavigator.Tab` per item) and the iPad
/// sidebar (`AppSidebarScreen` lists these items and swaps the split navigator's
/// detail column).
struct AppTabItem: Identifiable {
    let id: AppTab
    let title: String
    let systemImage: String
    let rootRoute: AnyRoute
    let makeNavigator: () -> StackNavigator
    let openInDetail: (SplitNavigator) -> Void
}

let appTabItems: [AppTabItem] = [
    AppTabItem(
        id: .discover,
        title: "discover",
        systemImage: "sparkles",
        rootRoute: AnyRoute(DiscoverRoute.discover),
        makeNavigator: { StackNavigator(root: DiscoverRoute.discover) },
        openInDetail: { $0.showDetail(DiscoverRoute.discover) }
    ),
    AppTabItem(
        id: .schedule,
        title: "schedule",
        systemImage: "calendar",
        rootRoute: AnyRoute(ScheduleRoute.list),
        makeNavigator: { StackNavigator(root: ScheduleRoute.list) },
        openInDetail: { $0.showDetail(ScheduleRoute.list) }
    ),
    AppTabItem(
        id: .myconf,
        title: "myconf",
        systemImage: "ticket",
        rootRoute: AnyRoute(MyConfRoute.overview),
        makeNavigator: { StackNavigator(root: MyConfRoute.overview) },
        openInDetail: { $0.showDetail(MyConfRoute.overview) }
    ),
    AppTabItem(
        id: .speakers,
        title: "speakers",
        systemImage: "person.2",
        rootRoute: AnyRoute(SpeakersRoute.overview),
        makeNavigator: { StackNavigator(root: SpeakersRoute.overview) },
        openInDetail: { $0.showDetail(SpeakersRoute.overview) }
    )
]
