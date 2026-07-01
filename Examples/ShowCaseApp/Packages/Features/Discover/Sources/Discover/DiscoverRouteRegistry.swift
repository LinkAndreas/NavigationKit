import NavigationKit
import SwiftUI

public enum DiscoverRouteBuilder {
    @MainActor
    public static func register<ScheduleRoute: Hashable, AccountRoute: Hashable>(
        in registry: RouteBuilder,
        scheduleRoute: ScheduleRoute,
        accountRoute: AccountRoute
    ) {
        registry.register(DiscoverRoute.self) { route, navigator in
            switch route {
            case .discover:
                DiscoverScreen(
                    openEventDetails: { navigator.push(DiscoverRoute.eventDetails) },
                    openKeynoteDetails: { id in navigator.push(DiscoverRoute.keynoteDetails(id: id)) },
                    openSchedule: { navigator.push(scheduleRoute) },
                    openAccount: { navigator.present(sheet: accountRoute) }
                )
            case .eventDetails:
                EventDetailsScreen()
            case .keynoteDetails(let id):
                KeynoteDetailsScreen(keynoteId: id)
            }
        }
    }
}
