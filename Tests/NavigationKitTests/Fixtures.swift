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

/// A flow without a result, starting at `FlowRoute.step1`.
struct OnboardingFlow: Flow {
    var start: FlowRoute { .step1 }
}

enum ProofStep: Route {
    case upload(required: Bool), link
}

/// A reusable flow from "another team", producing a proof string.
struct ProofFlow: Flow {
    typealias Result = String
    var required = true
    var start: ProofStep { .upload(required: required) }
}

enum RegistrationStep: Route {
    case team, summary(proof: String)

    var presentation: PresentationStyle? { self == .team ? .sheet : nil }
}

/// A flow that composes `ProofFlow`; its start step is a sheet, so the flow runs in one.
struct RegistrationFlow: Flow {
    typealias Result = Int
    var start: RegistrationStep { .team }
}
