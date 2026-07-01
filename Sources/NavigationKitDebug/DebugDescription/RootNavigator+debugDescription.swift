import Foundation
import NavigationKit

extension RootNavigator: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .stack(navigator): navigator.debugDescription
        case let .tabs(navigator): navigator.debugDescription
        case let .split(navigator): navigator.debugDescription
        }
    }
}
