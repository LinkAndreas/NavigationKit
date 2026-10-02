import Account
import Discover
import MyConf
import NavigationKit
import os
import Schedule
import Speakers
import SwiftUI

/// Every feature contributes its screens as a module. Modules that need app-provided
/// dependencies or cross-feature destinations receive them here.
@MainActor
let appModules: [any RouteModule] = [
    AccountModule(),
    MyConfModule(),
    SpeakersModule(),
    ScheduleModule(speakerAvatarProvider: { speakerId in
        SpeakerMock.speakers
            .first { $0.id == speakerId }
            .map { Image($0.imageName, bundle: SpeakerMock.speakersBundle) }
    }),
    DiscoverModule(scheduleRoute: ScheduleRoute.list, accountRoute: AccountRoute.profile),
]

/// Maps URLs to layout-independent steps. Each feature parses its own segments; the app only
/// decides where they are mounted — no tab-vs-split branching.
enum AppLinks: DeepLinks {
    static func steps(for url: URL) -> [Step]? {
        let segments = url.segments

        // navigator://schedule/session/42 → Schedule, session in the detail column (or pushed)
        if let routes = ScheduleDeepLink.parse(segments) {
            return [Step.select(AppTab.schedule)] + routes.dropFirst().map { Step.show($0) }
        }
        // navigator://myconf/dashboard/reward
        if let routes = MyConfDeepLink.parse(segments) {
            return [Step.select(AppTab.myconf)] + routes.dropFirst().map { Step.push($0) }
        }
        // navigator://speakers/speaker/s1
        if let routes = SpeakersDeepLink.parse(segments) {
            return [Step.select(AppTab.speakers)] + routes.dropFirst().map { Step.push($0) }
        }
        // navigator://account/settings → Discover, account sheet, settings inside it
        if let routes = AccountDeepLink.parse(segments), let root = routes.first {
            return [Step.select(AppTab.discover), .present(root)] + routes.dropFirst().map { Step.push($0) }
        }
        return nil
    }
}

/// One place for analytics and logging, instead of tracking calls in every screen.
enum NavigationAnalytics {
    private static let logger = Logger(subsystem: "ShowCaseApp", category: "navigation")

    static func track(_ event: NavigationEvent) {
        logger.debug("\(event.description, privacy: .public)")
    }
}
