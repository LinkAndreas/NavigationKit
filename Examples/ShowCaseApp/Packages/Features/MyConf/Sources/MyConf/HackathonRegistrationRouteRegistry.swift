import NavigationKit
import SwiftUI

extension HackathonRegistrationRoute {
    @MainActor @ViewBuilder
    func body(_ nav: RouteNavigator<MyConfRoute>) -> some View {
        switch self {
        case .teamSizeSelection:
            TeamSizeSelectionScreen(
                onProjectCategorySelectionTapped: { nav.push(.hackathonRegistration(.projectCategorySelection)) },
                onCancellationTapped: {
                    Task {
                        let cancel = await nav.confirm(
                            "Cancel Process?",
                            message: "Are you sure you want to cancel the activity submission? All progress will be lost.",
                            confirm: "Yes, cancel",
                            destructive: true
                        )
                        // Backing out of a flow resolves it as abandoned.
                        if cancel { nav.pop(to: .dashboard) }
                    }
                }
            )
        case .projectCategorySelection:
            ProjectCategorySelectionScreen(onNextTapped: { nav.push(.hackathonRegistration(.teamDetailsForm)) })
        case .teamDetailsForm:
            TeamDetailsFormScreen(
                onDocumentFlowTapped: { nav.push(.hackathonRegistration(.projectUpload(.documentOnly))) },
                onServiceProviderFlowTapped: { nav.push(.hackathonRegistration(.repositoryLinkEntry(.serviceProviderOnly))) },
                onDocumentOrServiceProviderFlowTapped: { nav.push(.hackathonRegistration(.verificationSelection)) },
                onDocumentAndServiceProviderFlowTapped: { nav.push(.hackathonRegistration(.projectUpload(.both))) }
            )
        case let .projectUpload(requirement):
            ProjectUploadScreen(
                flow: requirement,
                onNextTapped: {
                    nav.push(.hackathonRegistration(requirement == .both ? .repositoryLinkEntry(.both) : .summary))
                }
            )
        case let .repositoryLinkEntry(requirement):
            RepositoryLinkEntryScreen(flow: requirement, onNextTapped: { nav.push(.hackathonRegistration(.summary)) })
        case .verificationSelection:
            VerificationSelectionScreen(
                onDocumentTapped: { nav.push(.hackathonRegistration(.projectUpload(.documentOnly))) },
                onServiceProviderTapped: { nav.push(.hackathonRegistration(.repositoryLinkEntry(.serviceProviderOnly))) }
            )
        case .summary:
            HackathonRegistrationSummaryScreen(onBackToDashboardTapped: { nav.finishFlow() })
        }
    }
}
