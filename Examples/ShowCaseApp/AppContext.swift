import Account
import Schedule
import Discover
import NavigationKit
import MyConf
import Speakers
import SwiftUI
import UIKit

public enum AppTab: Hashable {
    case discover
    case schedule
    case myconf
    case speakers
}

final class AppContext {
    let navigator: RootNavigator
    let routeBuilder: RouteBuilder
    let deeplinkResolver: DeeplinkResolver

    /// iPad gets a sidebar + detail split navigator; iPhone keeps the tab bar.
    /// A `RootNavigator`'s case is fixed for its lifetime, so this is decided once at
    /// launch rather than adapting to size-class changes at runtime.
    private let isSplit = UIDevice.current.userInterfaceIdiom == .pad

    init() {
        // MARK: - Navigator

        // Built as a concrete `SplitNavigator` (not just `.split(...)`) so it can also be
        // captured below for the sidebar's own route registration.
        let splitNavigator: SplitNavigator?
        if isSplit {
            let split = SplitNavigator(
                sidebar: StackNavigator(root: AppSidebarRoute.menu),
                detail: appTabItems[0].makeNavigator(),
                columnVisibility: .all
            )
            splitNavigator = split
            navigator = .split(split)
        } else {
            splitNavigator = nil
            navigator = .tabs(
                TabsNavigator(
                    tabs: appTabItems.map { item in
                        TabsNavigator.Tab(
                            id: item.id,
                            title: item.title,
                            systemImage: item.systemImage,
                            navigator: item.makeNavigator()
                        )
                    },
                    selection: AppTab.discover
                )
            )
        }
        routeBuilder = RouteBuilder()

        // MARK: - Route Registration

        ScheduleRouteBuilder.register(
            in: routeBuilder,
            speakerAvatarProvider: { speakerId in
                if let speaker = SpeakerMock.speakers.first(where: { speaker in speaker.id == speakerId }) {
                    return Image(speaker.imageName, bundle: SpeakerMock.speakersBundle)
                }
                return nil
            }
        )
        AccountRouteBuilder.register(in: routeBuilder)
        DiscoverRouteBuilder.register(
            in: routeBuilder,
            scheduleRoute: ScheduleRoute.list,
            accountRoute: AccountRoute.profile
        )
        MyConfRouteBuilder.register(in: routeBuilder)
        SpeakersRouteBuilder.register(in: routeBuilder)

        if let splitNavigator {
            routeBuilder.register(AppSidebarRoute.self) { _, _ in
                AppSidebarScreen(items: appTabItems, splitNavigator: splitNavigator)
            }
        }

        // MARK: - Deeplink Resolver

        deeplinkResolver = DeeplinkResolver()

        // navigator://schedule/session/42 → select Schedule tab, push session inside it
        deeplinkResolver.register { [isSplit] url in
            guard let routes = ScheduleDeepLink.parse(url.segments) else { return nil }
            let stack = StackState(ScheduleRoute.list).pushing(all: Array(routes.dropFirst()))
            return isSplit
                ? SplitState(detail: stack).asState
                : TabsState(selection: AppTab.schedule, tabs: [AnyHashable(AppTab.schedule): stack]).asState
        }

        // navigator://myconf/dashboard/reward → select MyConf tab, push up to reward
        deeplinkResolver.register { [isSplit] url in
            guard let routes = MyConfDeepLink.parse(url.segments) else { return nil }
            let stack = StackState(MyConfRoute.overview).pushing(all: Array(routes.dropFirst()))
            return isSplit
                ? SplitState(detail: stack).asState
                : TabsState(selection: AppTab.myconf, tabs: [AnyHashable(AppTab.myconf): stack]).asState
        }

        // navigator://speakers/speaker/s1 → select Speakers tab, push speaker details
        deeplinkResolver.register { [isSplit] url in
            guard let routes = SpeakersDeepLink.parse(url.segments) else { return nil }
            let stack = StackState(SpeakersRoute.overview).pushing(all: Array(routes.dropFirst()))
            return isSplit
                ? SplitState(detail: stack).asState
                : TabsState(selection: AppTab.speakers, tabs: [AnyHashable(AppTab.speakers): stack]).asState
        }

        // navigator://account/settings → select Discover tab, select Account, push settings
        deeplinkResolver.register { [isSplit] url in
            guard let stackState = AccountDeepLink.parse(url.segments) else { return nil }
            let stack = StackState(DiscoverRoute.discover).presentingSheet(.stack(stackState))
            return isSplit
                ? SplitState(detail: stack).asState
                : TabsState(selection: AppTab.discover, tabs: [AnyHashable(AppTab.discover): stack]).asState
        }
    }
}
