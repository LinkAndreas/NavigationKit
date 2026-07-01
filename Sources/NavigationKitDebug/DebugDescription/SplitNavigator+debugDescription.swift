import Foundation
import NavigationKit

extension SplitNavigator: CustomDebugStringConvertible {
    public var debugDescription: String {
        var lines: [String] = []
        buildDebugDescription(into: &lines, indent: 0)
        return lines.joined(separator: "\n")
    }

    func buildDebugDescription(into lines: inout [String], indent: Int) {
        let prefix = String(repeating: "  ", count: indent)
        lines.append("\(prefix)◫ Split (\(columnVisibility))")
        lines.append("\(prefix)  Sidebar:")
        sidebar.buildDebugDescription(into: &lines, indent: indent + 2)
        if let content {
            lines.append("\(prefix)  Content:")
            content.buildDebugDescription(into: &lines, indent: indent + 2)
        }
        lines.append("\(prefix)  Detail:")
        detail.buildDebugDescription(into: &lines, indent: indent + 2)
        NavigatorDebugFormatting.appendModalLines(self, into: &lines, indent: indent)
    }
}
