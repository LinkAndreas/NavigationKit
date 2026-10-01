import NavigationKit
import SwiftUI

extension SwagRedemptionRoute {
    @MainActor @ViewBuilder
    func body(_ nav: RouteNavigator<MyConfRoute>) -> some View {
        switch self {
        case .swagSelection:
            SwagSelectionScreen(onNextTapped: { nav.push(.swagRedemption(.shippingAddressEntry)) })
        case .shippingAddressEntry:
            ShippingAddressEntryScreen(
                onToInvoiceDataTapped: { nav.push(.swagRedemption(.billingDetails)) },
                onToSummaryTapped: { nav.push(.swagRedemption(.summary)) }
            )
        case .billingDetails:
            BillingDetailsScreen(onNextTapped: { nav.push(.swagRedemption(.paymentMethod)) })
        case .paymentMethod:
            PaymentMethodScreen(onNextTapped: { nav.push(.swagRedemption(.summary)) })
        case .summary:
            SwagRedemptionSummaryScreen(onBackToDashboardTapped: { nav.finishFlow() })
        }
    }
}
