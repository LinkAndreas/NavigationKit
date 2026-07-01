import SwiftUI

enum AppearanceSetting: Int {
    case system = 0
    case light = 1
    case dark = 2
}

struct ColorSchemeModifier: ViewModifier {
    @AppStorage("appearance_setting") private var appearance: AppearanceSetting = .system

    var colorScheme: ColorScheme? {
        switch appearance {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }

    func body(content: Content) -> some View {
        content
            .preferredColorScheme(colorScheme)
    }
}

extension View {
    func withAppearanceSetting() -> some View {
        modifier(ColorSchemeModifier())
    }
}
