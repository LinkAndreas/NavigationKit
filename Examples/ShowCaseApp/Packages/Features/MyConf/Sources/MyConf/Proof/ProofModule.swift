import NavigationKit
import SwiftUI

/// The proof flow's screens. Steps continue with `push` and end with `finishFlow(returning:)`;
/// they never know which flow started them or what comes after.
struct ProofModule: TypedRouteModule {
    func body(for route: ProofRoute, nav: RouteNavigator<ProofRoute>) -> some View {
        // One draft per run of the flow, shared by its steps and released when the run ends.
        let draft = nav.remember(for: .flow) { ProofDraft() }

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
                    draft.proof.hasDocument = true
                    if requirement == .both {
                        nav.push(.repositoryLinkEntry(.both))
                    } else {
                        nav.finishFlow(returning: draft.proof)
                    }
                }
            )
        case let .repositoryLinkEntry(requirement):
            RepositoryLinkEntryScreen(
                flow: requirement,
                onNextTapped: {
                    draft.proof.hasRepositoryLink = true
                    nav.finishFlow(returning: draft.proof)
                }
            )
        }
    }
}

/// What the proof flow has collected so far.
final class ProofDraft {
    var proof = Proof()
}
