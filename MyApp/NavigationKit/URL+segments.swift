import Foundation

extension URL {
    /// `myapp://catalog/product/42` → ["catalog","product","42"]
    public var segments: [String] {
        ([host].compactMap { $0 }) + pathComponents.filter { $0 != "/" }
    }
}
