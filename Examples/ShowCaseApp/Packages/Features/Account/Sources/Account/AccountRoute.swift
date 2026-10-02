import NavigationKit

public enum AccountRoute: Route {
    case profile
    case personalInformation
    case notifications
    case paymentMethods
    case addPaymentMethod
    case settings

    /// Traits keep call sites to a single verb: `navigator.open(.addPaymentMethod)` presents a sheet.
    public var presentation: PresentationStyle? {
        switch self {
        case .addPaymentMethod: .sheet(detents: [.medium, .large])
        default: nil
        }
    }
}
