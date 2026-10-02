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

/// A flow without a result.
struct OnboardingFlow: Flow {
    enum Step: Hashable, Codable, Sendable { case welcome, permissions, profile }
    var start: Step { .welcome }
}

/// A reusable flow from "another team", producing a proof string.
struct ProofFlow: Flow {
    typealias Result = String
    enum Step: Hashable, Codable, Sendable { case upload(required: Bool), link }
    var required = true
    var start: Step { .upload(required: required) }
}

/// A flow that composes `ProofFlow` and runs in a sheet.
struct RegistrationFlow: Flow {
    typealias Result = Int
    enum Step: Hashable, Codable, Sendable { case team, summary(proof: String) }
    var start: Step { .team }
    var presentation: PresentationStyle? { .sheet }
}

/// The navigator a `FlowModule` hands to the topmost step of `F` on screen.
@MainActor
func flowNavigator<F: Flow>(_ store: NavigationStore, _: F.Type = F.self) -> FlowNavigator<F> {
    let step = store.activeStack.entries.reversed().lazy.compactMap { $0.route.as(FlowStepRoute<F>.self) }.first!
    return FlowNavigator(store.navigator, flow: step.flow, run: step.run)
}

/// The steps of `F` currently on screen, in order.
@MainActor
func shownSteps<F: Flow>(_ store: NavigationStore, _: F.Type) -> [F.Step] {
    store.currentSteps.compactMap { step -> F.Step? in
        switch step {
        case let .push(route), let .present(route, _), let .show(route): route.as(FlowStepRoute<F>.self)?.step
        case .select: nil
        }
    }
}
