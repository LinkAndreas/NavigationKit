import NavigationKit
import SwiftUI

/// The feature owns both its routes and its screens, so the route renders itself — no
/// registration needed anywhere.
extension AccountRoute: ViewRoute {
    public func body(_ nav: RouteNavigator<AccountRoute>) -> some View {
        switch self {
        case .profile:
            ProfileScreen(
                onPersonalInformationTapped: { nav.push(.personalInformation) },
                onNotificationsTapped: { nav.push(.notifications) },
                onPaymentMethodsTapped: { nav.push(.paymentMethods) },
                onSettingsTapped: { nav.push(.settings) },
                onLogoutTapped: {
                    Task {
                        if await nav.confirm("Log out?", confirm: "Log out", destructive: true) {
                            nav.dismiss()
                        }
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
                Task {
                    let confirmed = await nav.confirm(
                        "Delete Account",
                        message: "Are you sure you want to permanently delete your account?",
                        confirm: "Delete",
                        destructive: true
                    )
                    if confirmed { nav.popToRoot() }
                }
            })
        }
    }
}
