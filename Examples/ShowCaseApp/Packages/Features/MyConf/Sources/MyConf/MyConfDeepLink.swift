import NavigationKit

public enum MyConfDeepLink {
    public static func parse(_ segments: [String]) -> [any Route]? {
        guard segments.first == "myconf" else { return nil }
        
        let rest = Array(segments.dropFirst())
        var routes: [any Route] = [MyConfRoute.overview]
        
        if rest.isEmpty {
            return routes
        }
        
        switch rest[0] {
        case "participation":
            routes.append(MyConfRoute.participationStatement)
        case "savedSessions":
            routes.append(MyConfRoute.savedSessions)
        case "dashboard":
            routes.append(MyConfRoute.dashboard)
            
            if rest.count > 1 {
                switch rest[1] {
                case "reward":
                    routes.append(SwagRedemption())
                case "activity":
                    routes.append(HackathonRegistration())
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
