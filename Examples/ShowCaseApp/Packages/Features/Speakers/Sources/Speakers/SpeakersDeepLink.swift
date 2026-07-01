import Foundation

public enum SpeakersDeepLink {
    public static func parse(_ segments: [String]) -> [SpeakersRoute]? {
        guard segments.first == "speakers" else { return nil }
        
        let rest = Array(segments.dropFirst())
        var routes: [SpeakersRoute] = [.overview]
        
        if rest.isEmpty {
            return routes
        }
        
        switch rest[0] {
        case "speaker":
            if rest.count > 1 {
                let speakerId = rest[1]
                routes.append(.speakerDetails(id: speakerId))
            }
        default:
            break
        }
        
        return routes
    }
}
