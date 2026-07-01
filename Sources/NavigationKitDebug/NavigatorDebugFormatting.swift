import Foundation
import NavigationKit

/// Formatting shared by `StackNavigator`/`TabsNavigator`/`SplitNavigator`'s
/// `CustomDebugStringConvertible` conformances, so the tree-printing logic (used by
/// `NavigationKitDebug`) isn't duplicated per type.
@MainActor
enum NavigatorDebugFormatting {
    static func clean(_ value: Any) -> String {
        String(describing: value)
            .replacingOccurrences(of: "([A-Z][a-zA-Z0-9]*\\.)+", with: "", options: .regularExpression)
    }

    static func appendModalLines(_ presenter: any ModalPresenter, into lines: inout [String], indent: Int) {
        let prefix = String(repeating: "  ", count: indent)
        let modals = presenter.modals

        if let sheet = modals.sheet {
            lines.append("\(prefix)📄 Sheet")
            sheet.buildDebugDescription(into: &lines, indent: indent + 2)
        }

        if let fullScreenCover = modals.fullScreenCover {
            lines.append("\(prefix)🖥 Full Screen Cover")
            fullScreenCover.buildDebugDescription(into: &lines, indent: indent + 2)
        }

        if let alert = modals.alert {
            lines.append("\(prefix)⚠️ Alert: \(alert.title)")
        }
        if let confirmationDialog = modals.confirmationDialog {
            lines.append("\(prefix)📝 Confirmation Dialog: \(confirmationDialog.title)")
        }
        if let error = modals.error {
            lines.append("\(prefix)❌ Error: \(error.localizedDescription)")
        }
    }
}
