import NavigationKit
import SwiftUI

public enum AccountRouteBuilder {
    @MainActor
    public static func register(in registry: RouteBuilder) {
        registry.register(AccountRoute.self) { route, navigator in
            switch route {
            case .profile:
                ProfileScreen(
                    onPersonalInformationTapped: {
                        navigator.push(AccountRoute.personalInformation)
                    },
                    onNotificationsTapped: {
                        navigator.push(AccountRoute.notifications)
                    },
                    onPaymentMethodsTapped: {
                        navigator.push(AccountRoute.paymentMethods)
                    },
                    onSettingsTapped: {
                        navigator.push(AccountRoute.settings)
                    },
                    onLogoutTapped: {
                        navigator.present(
                            alert: AlertSpec(
                                title: "Log out?",
                                buttons: [
                                    AlertSpec.Button("Log out", role: .destructive) {
                                        navigator.dismiss()
                                    },
                                    AlertSpec.Button("cancel", role: .cancel)]
                            )
                        )
                    },
                    onCloseTapped: {
                        navigator.dismiss()
                    }
                )
            case .personalInformation:
                PersonalInformationScreen()
            case .notifications:
                NotificationsScreen()
            case .paymentMethods:
                PaymentMethodsScreen(
                    onAddPaymentMethodTapped: {
                        navigator.present(sheet: AccountRoute.addPaymentMethod)
                    }
                )
            case .addPaymentMethod:
                AddPaymentMethodScreen(
                    onSaveTapped: {
                        navigator.dismiss()
                    },
                    onCancelTapped: {
                        navigator.dismiss()
                    }
                )
            case .settings:
                SettingsScreen(
                    onDeleteAccountTapped: {
                        navigator.present(
                            alert: AlertSpec(
                                title: "Delete Account",
                                message: "Are you sure you want to permanently delete your account?",
                                buttons: [
                                    AlertSpec.Button("Delete", role: .destructive) {
                                        // mock delete and logout
                                        navigator.popToRoot()
                                    },
                                    AlertSpec.Button("cancel", role: .cancel)
                                ]
                            )
                        )
                    }
                )
            }
        }
    }
}
