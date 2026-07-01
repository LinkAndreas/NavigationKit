import Foundation

public enum ScheduleDeepLink {
    /// Root-relative routes this feature owns. Knows nothing about mounting.
    public static func parse(_ segments: [String]) -> [ScheduleRoute]? {
        guard segments.first == "schedule" else { return nil }
        let rest = Array(segments.dropFirst())
        if rest.isEmpty { return [.list] }
        if rest.count == 2, rest[0] == "session" {
            let id = rest[1]
            return [.list, .session(id: id)]
        }

        return nil
    }
}
