import NavigationKit
import SwiftUI

public struct AccountModule: TypedRouteModule {
    public init() {}

    public func body(for route: AccountRoute, nav: RouteNavigator<AccountRoute>) -> some View {
        switch route {
        case .profile:
            ProfileScreen(
                onPersonalInformationTapped: { nav.push(.personalInformation) },
                onNotificationsTapped: { nav.push(.notifications) },
                onPaymentMethodsTapped: { nav.push(.paymentMethods) },
                onSettingsTapped: { nav.push(.settings) },
                onLogoutTapped: {
                    nav.confirm("Log out?", confirm: "Log out", destructive: true) {
                        nav.dismiss()
                    }
                },
                onCloseTapped: { nav.dismiss() }
            )
        case .personalInformation:
            PersonalInformationScreen()
        case .notifications:
            NotificationsScreen()
        case .paymentMethods:
            PaymentMethodsScreen(onAddPaymentMethodTapped: { nav.open(.addPaymentMethod) })
        case .addPaymentMethod:
            AddPaymentMethodScreen(
                onSaveTapped: { nav.dismiss() },
                onCancelTapped: { nav.dismiss() }
            )
        case .settings:
            SettingsScreen(onDeleteAccountTapped: {
                nav.confirm(
                    "Delete Account",
                    message: "Are you sure you want to permanently delete your account?",
                    confirm: "Delete",
                    destructive: true
                ) {
                    nav.popToRoot()
                }
            })
        }
    }
}
