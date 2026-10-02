import NavigationKit
import SwiftUI

/// All MyConf screens, including its flows. The app lists this one module.
public struct MyConfModule: RouteModule {
    public init() {}

    public func register(in registry: RouteRegistry) {
        registry.add(MyConfScreens())
        registry.add(SwagRedemptionModule())
        registry.add(HackathonRegistrationModule())
        registry.add(ProofModule())
    }
}

struct MyConfScreens: TypedRouteModule {
    func body(for route: MyConfRoute, nav: RouteNavigator<MyConfRoute>) -> some View {
        switch route {
        case .overview:
            OverviewScreen(
                onScanQRCodeTapped: { nav.open(.scanQRCode) },
                onSavedSessionsTapped: { nav.push(.savedSessions) }
            )
        case .participationStatement:
            ParticipationStatementScreen(onJoinTapped: { nav.popToRoot() })
        case .dashboard:
            // The dashboard starts each process as a whole; it doesn't know their screens.
            DashboardScreen(
                onApplyForRewardTapped: { nav.flow(SwagRedemption()) },
                onSubmitActivityTapped: { nav.flow(HackathonRegistration()) }
            )
        case .savedSessions:
            SavedSessionsScreen()
        case .scanQRCode:
            QRScannerScreen(onDismissTapped: { nav.dismiss() })
        }
    }
}

struct SwagRedemptionModule: TypedRouteModule {
    func body(for route: SwagRedemptionRoute, nav: RouteNavigator<SwagRedemptionRoute>) -> some View {
        switch route {
        case .swagSelection:
            SwagSelectionScreen(onNextTapped: { nav.push(.shippingAddressEntry) })
        case .shippingAddressEntry:
            ShippingAddressEntryScreen(
                onToInvoiceDataTapped: { nav.push(.billingDetails) },
                onToSummaryTapped: { nav.push(.summary) }
            )
        case .billingDetails:
            BillingDetailsScreen(onNextTapped: { nav.push(.paymentMethod) })
        case .paymentMethod:
            PaymentMethodScreen(onNextTapped: { nav.push(.summary) })
        case .summary:
            SwagRedemptionSummaryScreen(onBackToDashboardTapped: { nav.finishFlow() })
        }
    }
}

struct HackathonRegistrationModule: TypedRouteModule {
    func body(for route: HackathonRegistrationRoute, nav: RouteNavigator<HackathonRegistrationRoute>) -> some View {
        switch route {
        case .teamSizeSelection:
            TeamSizeSelectionScreen(
                onProjectCategorySelectionTapped: { nav.push(.projectCategorySelection) },
                onCancellationTapped: {
                    nav.confirm(
                        "Cancel Process?",
                        message: "Are you sure you want to cancel the activity submission? All progress will be lost.",
                        confirm: "Yes, cancel",
                        destructive: true
                    ) {
                        nav.cancelFlow()
                    }
                }
            )
        case .projectCategorySelection:
            ProjectCategorySelectionScreen(onNextTapped: { nav.push(.teamDetailsForm) })
        case .teamDetailsForm:
            // Proof collection is another flow: run it as one step and continue with its result.
            TeamDetailsFormScreen(onProofRequirementSelected: { requirement in
                nav.flow(ProofFlow(requirement: requirement)) { proof in
                    nav.push(.summary(proof))
                }
            })
        case let .summary(proof):
            HackathonRegistrationSummaryScreen(proof: proof, onBackToDashboardTapped: { nav.finishFlow() })
        }
    }
}
