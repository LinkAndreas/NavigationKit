import Foundation
import NavigationKit

extension StackNavigator: CustomDebugStringConvertible {
    public var debugDescription: String {
        var lines: [String] = []
        buildDebugDescription(into: &lines, indent: 0)
        return lines.joined(separator: "\n")
    }

    func buildDebugDescription(into lines: inout [String], indent: Int) {
        let prefix = String(repeating: "  ", count: indent)
        lines.append("\(prefix)🗂 Stack")
        lines.append("\(prefix)  Root: \(NavigatorDebugFormatting.clean(root.wrapped.base))")
        if !path.isEmpty {
            lines.append("\(prefix)  Path:")
            for (index, route) in path.enumerated() {
                lines.append("\(prefix)    \(index + 1). \(NavigatorDebugFormatting.clean(route.wrapped.base))")
            }
        }
        NavigatorDebugFormatting.appendModalLines(self, into: &lines, indent: indent)
    }
}
