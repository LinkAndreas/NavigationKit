import Foundation

public enum AccountDeepLink {
    public static func parse(_ segments: [String]) -> [AccountRoute]? {
        guard segments.first == "account" else { return nil }
        switch Array(segments.dropFirst()) {
        case []:           return [.profile]
        case ["settings"]: return [.profile, .settings]   // profile + settings pushed
        default:           return nil
        }
    }
}
