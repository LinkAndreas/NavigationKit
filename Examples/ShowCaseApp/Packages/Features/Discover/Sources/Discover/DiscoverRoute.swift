import Foundation

public enum DiscoverRoute: Hashable {
    case discover
    case eventDetails
    case keynoteDetails(id: String)
}
