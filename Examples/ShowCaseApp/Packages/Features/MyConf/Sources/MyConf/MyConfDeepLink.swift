import Foundation

public enum MyConfDeepLink {
    public static func parse(_ segments: [String]) -> [MyConfRoute]? {
        guard segments.first == "myconf" else { return nil }
        
        let rest = Array(segments.dropFirst())
        var routes: [MyConfRoute] = [.overview]
        
        if rest.isEmpty {
            return routes
        }
        
        switch rest[0] {
        case "participation":
            routes.append(.participationStatement)
        case "savedSessions":
            routes.append(.savedSessions)
        case "dashboard":
            routes.append(.dashboard)
            
            if rest.count > 1 {
                switch rest[1] {
                case "reward":
                    routes.append(.swagRedemption(.swagSelection))
                case "activity":
                    routes.append(.hackathonRegistration(.teamSizeSelection))
                default:
                    // If we don't recognize the subsequent path, we gracefully degrade
                    // and just return what we have so far ([.overview, .dashboard])
                    break
                }
            }
        default:
            // Unrecognized path, just return the overview
            break
        }
        
        return routes
    }
}
