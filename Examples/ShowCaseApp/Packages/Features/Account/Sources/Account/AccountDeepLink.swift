import Foundation
import NavigationKit

public enum AccountDeepLink {
    public static func parse(_ segments: [String]) -> StackState? {
        guard segments.first == "account" else { return nil }

        switch Array(segments.dropFirst()) {
        case []:
            return StackState(AccountRoute.profile)
        case ["settings"]:
            return StackState(AccountRoute.profile)
                .pushing(AccountRoute.settings)
        default:
            return nil
        }
    }
}
