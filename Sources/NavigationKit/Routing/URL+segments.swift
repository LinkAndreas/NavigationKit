import Foundation

extension URL {
    /// Extracts the semantic components of a URL for deep linking.
    ///
    /// This property flattens the URL's host and path components into a single array of string segments,
    /// dropping any trailing or leading root slashes (`/`). This allows deep link handlers to easily `switch`
    /// over an array of path parts.
    ///
    /// **Example Usage:**
    /// ```swift
    /// let url = URL(string: "myapp://schedule/session/42")!
    /// print(url.segments) // Prints: ["schedule", "session", "42"]
    /// ```
    public var segments: [String] {
        ([host].compactMap { $0 }) + pathComponents.filter { $0 != "/" }
    }
}
