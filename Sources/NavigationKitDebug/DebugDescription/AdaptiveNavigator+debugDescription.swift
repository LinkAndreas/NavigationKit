import Foundation
import NavigationKit

extension AdaptiveNavigator: CustomDebugStringConvertible {
    public var debugDescription: String {
        var lines: [String] = []
        buildDebugDescription(into: &lines, indent: 0)
        return lines.joined(separator: "\n")
    }

    func buildDebugDescription(into lines: inout [String], indent: Int) {
        let prefix = String(repeating: "  ", count: indent)
        lines.append("\(prefix)⇄ Adaptive (\(layout.map { "\($0)" } ?? "not shown"))")
        lines.append("\(prefix)  Compact:")
        compact.buildDebugDescription(into: &lines, indent: indent + 2)
        lines.append("\(prefix)  Regular:")
        regular.buildDebugDescription(into: &lines, indent: indent + 2)
        NavigatorDebugFormatting.appendModalLines(self, into: &lines, indent: indent)
    }
}
