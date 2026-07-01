import NavigationKit
import SwiftUI

public enum MyConfRouteBuilder {
    @MainActor
    public static func register(in registry: RouteBuilder) {
        registry.register(MyConfRoute.self) { route, navigator in
            switch route {
            case .overview:
                OverviewScreen(
                    onScanQRCodeTapped: { navigator.present(sheet: MyConfRoute.scanQRCode) },
                    onSavedSessionsTapped: { navigator.push(MyConfRoute.savedSessions) }
                )
            case .participationStatement:
                ParticipationStatementScreen(
                    onJoinTapped: { navigator.popToRoot() }
                )
            case .dashboard:
                DashboardScreen(
                    onApplyForRewardTapped: { navigator.push(MyConfRoute.swagRedemption(.swagSelection)) },
                    onSubmitActivityTapped: { navigator.push(MyConfRoute.hackathonRegistration(.teamSizeSelection)) }
                )
            case .savedSessions:
                SavedSessionsScreen()
            case .scanQRCode:
                QRScannerScreen(
                    onDismissTapped: { navigator.dismiss() }
                )
            case let .swagRedemption(subRoute):
                SwagRedemptionRouteBuilder.resolve(route: subRoute, navigator: navigator)
            case let .hackathonRegistration(subRoute):
                HackathonRegistrationRouteBuilder.resolve(route: subRoute, navigator: navigator)
            }
        }
    }
}
