import Foundation

public enum CatalogDeepLink {
    /// Root-relative routes this feature owns. Knows nothing about mounting.
    public static func parse(_ segments: [String]) -> [CatalogRoute]? {
        guard segments.first == "catalog" else { return nil }
        let rest = Array(segments.dropFirst())
        if rest.isEmpty { return [.list] }
        if rest.count == 2, rest[0] == "product", let id = Int(rest[1]) {
            return [.list, .product(id: id)]
        }
        return nil
    }
}
