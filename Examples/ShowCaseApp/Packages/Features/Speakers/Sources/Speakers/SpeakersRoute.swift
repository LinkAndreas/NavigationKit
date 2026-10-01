import NavigationKit

public enum SpeakersRoute: Route {
    case overview
    case speakerDetails(id: String)
    case contactSpeaker(email: String)

    public var presentation: PresentationStyle? {
        if case .contactSpeaker = self { .sheet } else { nil }
    }
}
