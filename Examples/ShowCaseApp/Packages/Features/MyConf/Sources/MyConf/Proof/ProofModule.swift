import NavigationKit
import SwiftUI

/// The proof flow's screens. Steps continue with `next` and end with `finish`; they never know
/// which flow started them or what comes after.
struct ProofScreens: FlowModule {
    func body(for step: ProofFlow.Step, in flow: ProofFlow, navigator: FlowNavigator<ProofFlow>) -> some View {
        WithDependency(for: .flow) { ProofDraft() } content: { draft in
            switch step {
            case .verificationSelection:
                VerificationSelectionScreen(
                    onDocumentTapped: { navigator.next(.projectUpload(.documentOnly)) },
                    onServiceProviderTapped: { navigator.next(.repositoryLinkEntry(.serviceProviderOnly)) }
                )
            case let .projectUpload(requirement):
                ProjectUploadScreen(
                    flow: requirement,
                    onNextTapped: {
                        draft.proof.hasDocument = true
                        if requirement == .both {
                            navigator.next(.repositoryLinkEntry(.both))
                        } else {
                            navigator.finish(draft.proof)
                        }
                    }
                )
            case let .repositoryLinkEntry(requirement):
                RepositoryLinkEntryScreen(
                    flow: requirement,
                    onNextTapped: {
                        draft.proof.hasRepositoryLink = true
                        navigator.finish(draft.proof)
                    }
                )
            }
        }
    }
}

/// What the proof flow has collected so far — one per run of the flow.
final class ProofDraft {
    var proof = Proof()
}
