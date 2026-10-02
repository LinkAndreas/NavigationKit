import NavigationKit
import SwiftUI

/// Discover links to Schedule and Account without importing them: the app injects the
/// destination routes when it lists this module.
public struct DiscoverModule<Schedule: Route, Account: Route>: NavigationModule {
    private let scheduleRoute: Schedule
    private let accountRoute: Account

    public init(scheduleRoute: Schedule, accountRoute: Account) {
        self.scheduleRoute = scheduleRoute
        self.accountRoute = accountRoute
    }

    @MainActor
    public func register(in registry: RouteRegistry) {
        registry.register { [scheduleRoute, accountRoute] (route: DiscoverRoute, navigator) in
            switch route {
            case .discover:
                DiscoverScreen(
                    openEventDetails: { navigator.push(.eventDetails) },
                    openKeynoteDetails: { navigator.push(.keynoteDetails(id: $0)) },
                    openSchedule: { navigator.push(scheduleRoute) },
                    openAccount: { navigator.present(accountRoute) }
                )
            case .eventDetails:
                EventDetailsScreen()
            case let .keynoteDetails(id):
                KeynoteDetailsScreen(keynoteId: id)
            }
        }
    }
}
