import NavigationKit
import SwiftUI

public enum SwagRedemptionRouteBuilder {
    @MainActor @ViewBuilder
    public static func resolve(route: SwagRedemptionRoute, navigator: StackNavigator) -> some View {
        switch route {
        case .swagSelection:
            SwagSelectionScreen(
                onNextTapped: { navigator.push(MyConfRoute.swagRedemption(.shippingAddressEntry)) }
            )
        case .shippingAddressEntry:
            ShippingAddressEntryScreen(
                onToInvoiceDataTapped: { navigator.push(MyConfRoute.swagRedemption(.billingDetails)) },
                onToSummaryTapped: { navigator.push(MyConfRoute.swagRedemption(.summary)) }
            )
        case .billingDetails:
            BillingDetailsScreen(
                onNextTapped: { navigator.push(MyConfRoute.swagRedemption(.paymentMethod)) }
            )
        case .paymentMethod:
            PaymentMethodScreen(
                onNextTapped: { navigator.push(MyConfRoute.swagRedemption(.summary)) }
            )
        case .summary:
            SwagRedemptionSummaryScreen(
                onBackToDashboardTapped: { navigator.popTo(MyConfRoute.dashboard) }
            )
        }
    }
}
