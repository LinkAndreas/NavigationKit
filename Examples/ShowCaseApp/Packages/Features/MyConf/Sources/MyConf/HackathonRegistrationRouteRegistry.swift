import NavigationKit
import SwiftUI

public enum HackathonRegistrationRouteBuilder {
    @MainActor @ViewBuilder
    public static func resolve(route: HackathonRegistrationRoute, navigator: StackNavigator) -> some View {
        switch route {
        case .teamSizeSelection:
            TeamSizeSelectionScreen(
                onProjectCategorySelectionTapped: {
                    navigator.push(MyConfRoute.hackathonRegistration(.projectCategorySelection))
                },
                onCancellationTapped: {
                    navigator.present(alert: AlertSpec(
                        title: "Cancel Process?",
                        message: "Are you sure you want to cancel the activity submission? All progress will be lost.",
                        buttons: [
                            AlertSpec.Button("No, continue", role: .cancel),
                            AlertSpec.Button("Yes, cancel", role: .destructive) {
                                navigator.popTo(MyConfRoute.dashboard)
                            }
                        ]
                    ))
                }
            )
        case .projectCategorySelection:
            ProjectCategorySelectionScreen(
                onNextTapped: { navigator.push(MyConfRoute.hackathonRegistration(.teamDetailsForm)) }
            )
        case .teamDetailsForm:
            TeamDetailsFormScreen(
                onDocumentFlowTapped: { navigator.push(MyConfRoute.hackathonRegistration(.projectUpload(.documentOnly))) },
                onServiceProviderFlowTapped: { navigator.push(MyConfRoute.hackathonRegistration(.repositoryLinkEntry(.serviceProviderOnly))) },
                onDocumentOrServiceProviderFlowTapped: { navigator.push(MyConfRoute.hackathonRegistration(.verificationSelection)) },
                onDocumentAndServiceProviderFlowTapped: { navigator.push(MyConfRoute.hackathonRegistration(.projectUpload(.both))) }
            )
        case let .projectUpload(flow):
            ProjectUploadScreen(
                flow: flow,
                onNextTapped: {
                    if flow == .both {
                        navigator.push(MyConfRoute.hackathonRegistration(.repositoryLinkEntry(.both)))
                    } else {
                        navigator.push(MyConfRoute.hackathonRegistration(.summary))
                    }
                }
            )
        case let .repositoryLinkEntry(flow):
            RepositoryLinkEntryScreen(
                flow: flow,
                onNextTapped: { navigator.push(MyConfRoute.hackathonRegistration(.summary)) }
            )
        case .verificationSelection:
            VerificationSelectionScreen(
                onDocumentTapped: { navigator.push(MyConfRoute.hackathonRegistration(.projectUpload(.documentOnly))) },
                onServiceProviderTapped: { navigator.push(MyConfRoute.hackathonRegistration(.repositoryLinkEntry(.serviceProviderOnly))) }
            )
        case .summary:
            HackathonRegistrationSummaryScreen(
                onBackToDashboardTapped: { navigator.popTo(MyConfRoute.dashboard) }
            )
        }
    }
}
