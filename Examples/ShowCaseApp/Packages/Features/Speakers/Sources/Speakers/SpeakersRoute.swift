import Foundation

public enum SpeakersRoute: Hashable {
    case overview
    case speakerDetails(id: String)
    case contactSpeaker(email: String)
}
