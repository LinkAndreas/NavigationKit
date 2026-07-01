import NavigationKit
import SwiftUI

public enum SpeakersRouteBuilder {
    @MainActor
    public static func register(in registry: RouteBuilder) {
        registry.register(SpeakersRoute.self) { route, navigator in
            switch route {
            case .overview:
                OverviewScreen(
                    onSpeakerTapped: { id in
                        navigator.push(SpeakersRoute.speakerDetails(id: id))
                    }
                )
            case let .speakerDetails(id):
                SpeakerDetailsScreen(
                    speakerId: id,
                    onContactTapped: { email in
                        navigator.present(sheet: SpeakersRoute.contactSpeaker(email: email))
                    }
                )
            case let .contactSpeaker(email):
                MailView(
                    email: email,
                    subject: "WWDC 2026 Session Inquiry",
                    onDismiss: { navigator.dismiss() }
                )
            }
        }
    }
}
