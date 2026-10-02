import NavigationKit
import SwiftUI

public struct SpeakersModule: RouteModule {
    public init() {}

    public func body(for route: SpeakersRoute, navigator: RouteNavigator<SpeakersRoute>) -> some View {
        switch route {
        case .overview:
            OverviewScreen(onSpeakerTapped: { navigator.push(.speakerDetails(id: $0)) })
        case let .speakerDetails(id):
            SpeakerDetailsScreen(
                speakerId: id,
                onContactTapped: { navigator.open(.contactSpeaker(email: $0)) }
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
