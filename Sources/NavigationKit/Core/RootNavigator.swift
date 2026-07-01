import Foundation

/// A type-erased reference to one of the three navigator shapes.
///
/// Used wherever a caller needs to hold or render "a navigator" without committing to a
/// specific shape up front — an app's root navigator, `NavigationContainer`'s parameter, or
/// `applyDeepLink`'s target. Each shape is its own concrete `@Observable` class
/// (``StackNavigator``, ``TabsNavigator``, ``SplitNavigator``); this enum is the only place a
/// "kind" concept still exists, and the compiler enforces exhaustiveness on it, unlike a flag
/// checked ad hoc at each call site.
@MainActor
public enum RootNavigator: Identifiable {
    case stack(StackNavigator)
    case tabs(TabsNavigator)
    case split(SplitNavigator)

    public nonisolated var id: ObjectIdentifier {
        switch self {
        case let .stack(navigator): navigator.id
        case let .tabs(navigator): navigator.id
        case let .split(navigator): navigator.id
        }
    }
}
