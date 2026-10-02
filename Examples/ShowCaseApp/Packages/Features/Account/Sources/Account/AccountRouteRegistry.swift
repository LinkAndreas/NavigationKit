import NavigationKit
import SwiftUI

public struct AccountModule: RouteModule {
    public init() {}

    public func body(for route: AccountRoute, navigator: RouteNavigator<AccountRoute>) -> some View {
        switch route {
        case .profile:
            ProfileScreen(
                onPersonalInformationTapped: { navigator.push(.personalInformation) },
                onNotificationsTapped: { navigator.push(.notifications) },
                onPaymentMethodsTapped: { navigator.push(.paymentMethods) },
                onSettingsTapped: { navigator.push(.settings) },
                onLogoutTapped: {
                    navigator.confirm("Log out?", confirm: "Log out", destructive: true) {
                        navigator.dismiss()
                    }
                },
                onCloseTapped: { navigator.dismiss() }
            )
        case .personalInformation:
            PersonalInformationScreen()
        case .notifications:
            NotificationsScreen()
        case .paymentMethods:
            PaymentMethodsScreen(onAddPaymentMethodTapped: { navigator.open(.addPaymentMethod) })
        case .addPaymentMethod:
            AddPaymentMethodScreen(
                onSaveTapped: { navigator.dismiss() },
                onCancelTapped: { navigator.dismiss() }
            )
        case .settings:
            SettingsScreen(onDeleteAccountTapped: {
                navigator.confirm(
                    "Delete Account",
                    message: "Are you sure you want to permanently delete your account?",
                    confirm: "Delete",
                    destructive: true
                ) {
                    navigator.popToRoot()
                }
            })
        }
    }
}
