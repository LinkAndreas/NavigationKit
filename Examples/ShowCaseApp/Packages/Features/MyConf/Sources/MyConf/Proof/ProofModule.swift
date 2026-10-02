import NavigationKit
import SwiftUI

/// The proof flow's screens. Its steps continue with `push` and end with `finishFlow(returning:)`;
/// they never know which flow started them or what comes after.
struct ProofModule: TypedRouteModule {
    func body(for route: ProofRoute, nav: RouteNavigator<ProofRoute>) -> some View {
        switch route {
        case .verificationSelection:
            VerificationSelectionScreen(
                onDocumentTapped: { nav.push(.projectUpload(.documentOnly)) },
                onServiceProviderTapped: { nav.push(.repositoryLinkEntry(.serviceProviderOnly)) }
            )
        case let .projectUpload(requirement):
            ProjectUploadScreen(
                flow: requirement,
                onNextTapped: {
                    if requirement == .both {
                        nav.push(.repositoryLinkEntry(.both))
                    } else {
                        nav.finishFlow(returning: Proof(hasDocument: true))
                    }
                }
            )
        case let .repositoryLinkEntry(requirement):
            RepositoryLinkEntryScreen(
                flow: requirement,
                onNextTapped: {
                    nav.finishFlow(returning: Proof(hasDocument: requirement == .both, hasRepositoryLink: true))
                }
            )
        }
    }
}
