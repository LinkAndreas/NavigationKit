import Foundation

public enum AccountDeepLink {
    /// Root-relative routes this feature owns; the app decides where they are mounted.
    public static func parse(_ segments: [String]) -> [AccountRoute]? {
        guard segments.first == "account" else { return nil }

        switch Array(segments.dropFirst()) {
        case []:
            return [.profile]
        case ["settings"]:
            return [.profile, .settings]
        default:
            return nil
        }
    }
}
