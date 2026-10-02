import NavigationKit
import SwiftUI

public struct SpeakersModule: TypedRouteModule {
    public init() {}

    public func body(for route: SpeakersRoute, nav: RouteNavigator<SpeakersRoute>) -> some View {
        switch route {
        case .overview:
            OverviewScreen(onSpeakerTapped: { nav.push(.speakerDetails(id: $0)) })
        case let .speakerDetails(id):
            SpeakerDetailsScreen(
                speakerId: id,
                onContactTapped: { nav.open(.contactSpeaker(email: $0)) }
            )
        case let .contactSpeaker(email):
            MailView(
                email: email,
                subject: "WWDC 2026 Session Inquiry",
                onDismiss: { nav.dismiss() }
            )
        }
    }
}
