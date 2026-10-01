import NavigationKit
import SwiftUI

extension MyConfRoute: ViewRoute {
    public func body(_ nav: RouteNavigator<MyConfRoute>) -> some View {
        switch self {
        case .overview:
            OverviewScreen(
                onScanQRCodeTapped: { nav.open(.scanQRCode) },
                onSavedSessionsTapped: { nav.push(.savedSessions) }
            )
        case .participationStatement:
            ParticipationStatementScreen(onJoinTapped: { nav.popToRoot() })
        case .dashboard:
            // Both processes are flows: whatever screens they push, `finishFlow()` unwinds
            // exactly those — the dashboard no longer has to be named as the place to return to.
            DashboardScreen(
                onApplyForRewardTapped: { Task { await nav.flow(.swagRedemption(.swagSelection)) } },
                onSubmitActivityTapped: { Task { await nav.flow(.hackathonRegistration(.teamSizeSelection)) } }
            )
        case .savedSessions:
            SavedSessionsScreen()
        case .scanQRCode:
            QRScannerScreen(onDismissTapped: { nav.dismiss() })
        case let .swagRedemption(step):
            step.body(nav)
        case let .hackathonRegistration(step):
            step.body(nav)
        }
    }
}
