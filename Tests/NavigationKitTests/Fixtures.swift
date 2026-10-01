import Foundation
@testable import NavigationKit

enum AppTab: Hashable, Sendable { case home, schedule, account }

enum HomeRoute: Route {
    case feed
    case profile(id: String)
    case settings
    case login

    var presentation: PresentationStyle? {
        switch self {
        case .settings: .sheet(detents: [.medium])
        case .login: .cover
        default: nil
        }
    }

    var requiresAuth: Bool { self == .settings }
}

enum ScheduleRoute: Route {
    case list, placeholder, session(id: String), speaker(id: String)
}

enum FlowRoute: Route {
    case step1, step2, step3
}

@MainActor
func makeStore(layout: NavigationLayout = .tabs) -> NavigationStore {
    NavigationStore(layout: layout, selection: AppTab.home, sections: [
        RootSection(AppTab.home, "Home", icon: "house") { HomeRoute.feed },
        RootSection(AppTab.schedule, "Schedule", icon: "calendar") { ScheduleRoute.list } detail: { ScheduleRoute.placeholder },
    ])
}

/// Lets tasks spawned by the store (guards, auth, async navigation) run.
@MainActor
func settle() async {
    for _ in 0..<20 { await Task.yield() }
}
