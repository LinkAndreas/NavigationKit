import NavigationKit
import SwiftUI

/// All MyConf screens, including its flows. The app lists this one module.
public struct MyConfModule: NavigationModule {
    public init() {}

    public func register(in registry: RouteRegistry) {
        registry.add(MyConfScreens())
        registry.add(SwagRedemptionScreens())
        registry.add(HackathonRegistrationScreens())
        registry.add(ProofScreens())
    }
}

struct MyConfScreens: RouteModule {
    func body(for route: MyConfRoute, navigator: RouteNavigator<MyConfRoute>) -> some View {
        switch route {
        case .overview:
            OverviewScreen(
                onScanQRCodeTapped: { navigator.open(.scanQRCode) },
                onSavedSessionsTapped: { navigator.push(.savedSessions) }
            )
        case .participationStatement:
            ParticipationStatementScreen(onJoinTapped: { navigator.popToRoot() })
        case .dashboard:
            // The dashboard starts each process as a whole; it doesn't know their screens.
            DashboardScreen(
                onApplyForRewardTapped: { navigator.flow(SwagRedemption()) },
                onSubmitActivityTapped: { navigator.flow(HackathonRegistration()) }
            )
        case .savedSessions:
            SavedSessionsScreen()
        case .scanQRCode:
            QRScannerScreen(onDismissTapped: { navigator.dismiss() })
        }
    }
}

struct SwagRedemptionScreens: FlowModule {
    func body(for step: SwagRedemption.Step, in flow: SwagRedemption, navigator: FlowNavigator<SwagRedemption>) -> some View {
        switch step {
        case .swagSelection:
            SwagSelectionScreen(onNextTapped: { navigator.next(.shippingAddressEntry) })
        case .shippingAddressEntry:
            ShippingAddressEntryScreen(
                onToInvoiceDataTapped: { navigator.next(.billingDetails) },
                onToSummaryTapped: { navigator.next(.summary) }
            )
        case .billingDetails:
            BillingDetailsScreen(onNextTapped: { navigator.next(.paymentMethod) })
        case .paymentMethod:
            PaymentMethodScreen(onNextTapped: { navigator.next(.summary) })
        case .summary:
            SwagRedemptionSummaryScreen(onBackToDashboardTapped: { navigator.finish() })
        }
    }
}

struct HackathonRegistrationScreens: FlowModule {
    func body(
        for step: HackathonRegistration.Step,
        in flow: HackathonRegistration,
        navigator: FlowNavigator<HackathonRegistration>
    ) -> some View {
        switch step {
        case .teamSizeSelection:
            TeamSizeSelectionScreen(
                onProjectCategorySelectionTapped: { navigator.next(.projectCategorySelection) },
                onCancellationTapped: {
                    navigator.confirm(
                        "Cancel Process?",
                        message: "Are you sure you want to cancel the activity submission? All progress will be lost.",
                        confirm: "Yes, cancel",
                        destructive: true
                    ) {
                        navigator.cancel()
                    }
                }
            )
        case .projectCategorySelection:
            ProjectCategorySelectionScreen(onNextTapped: { navigator.next(.teamDetailsForm) })
        case .teamDetailsForm:
            // Proof collection is another flow: run it as one step and continue with its result.
            TeamDetailsFormScreen(onProofRequirementSelected: { requirement in
                navigator.flow(ProofFlow(requirement: requirement)) { proof in
                    navigator.next(.summary(proof))
                }
            })
        case let .summary(proof):
            HackathonRegistrationSummaryScreen(proof: proof, onBackToDashboardTapped: { navigator.finish() })
        }
    }
}
