import Foundation

extension URL {
    /// The host followed by the path components: `myapp://schedule/session/42` → `["schedule", "session", "42"]`.
    public var segments: [String] {
        ([host].compactMap { $0 }) + pathComponents.filter { $0 != "/" }
    }
}
