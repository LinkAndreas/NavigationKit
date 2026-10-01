import NavigationKit

public enum ScheduleRoute: Route {
    case list
    case session(id: String)
    /// Shown in the detail column of a split view before a session is selected.
    case placeholder
}
