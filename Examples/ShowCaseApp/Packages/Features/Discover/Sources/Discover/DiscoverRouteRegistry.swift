import NavigationKit
import SwiftUI

/// Discover links to Schedule and Account without importing them: the app injects the
/// destination routes when it lists this module.
public struct DiscoverModule<Schedule: Route, Account: Route>: RouteModule {
    private let scheduleRoute: Schedule
    private let accountRoute: Account

    public init(scheduleRoute: Schedule, accountRoute: Account) {
        self.scheduleRoute = scheduleRoute
        self.accountRoute = accountRoute
    }

    @MainActor
    public func register(in registry: RouteRegistry) {
        registry.register { [scheduleRoute, accountRoute] (route: DiscoverRoute, nav) in
            switch route {
            case .discover:
                DiscoverScreen(
                    openEventDetails: { nav.push(.eventDetails) },
                    openKeynoteDetails: { nav.push(.keynoteDetails(id: $0)) },
                    openSchedule: { nav.push(scheduleRoute) },
                    openAccount: { nav.present(accountRoute) }
                )
            case .eventDetails:
                EventDetailsScreen()
            case let .keynoteDetails(id):
                KeynoteDetailsScreen(keynoteId: id)
            }
        }
    }
}
