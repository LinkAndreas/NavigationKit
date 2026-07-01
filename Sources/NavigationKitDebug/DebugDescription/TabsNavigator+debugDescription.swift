import Foundation
import NavigationKit

extension TabsNavigator: CustomDebugStringConvertible {
    public var debugDescription: String {
        var lines: [String] = []
        buildDebugDescription(into: &lines, indent: 0)
        return lines.joined(separator: "\n")
    }

    func buildDebugDescription(into lines: inout [String], indent: Int) {
        let prefix = String(repeating: "  ", count: indent)
        lines.append("\(prefix)📑 Tabs")
        if let selection {
            lines.append("\(prefix)  Selection: \(NavigatorDebugFormatting.clean(selection.base))")
        }
        for tab in tabs {
            let isSelected = tab.id == selection
            lines.append("\(prefix)  \(isSelected ? "🟢" : "⚪️") Tab: \(tab.title)")
            tab.navigator.buildDebugDescription(into: &lines, indent: indent + 2)
        }
        NavigatorDebugFormatting.appendModalLines(self, into: &lines, indent: indent)
    }
}
