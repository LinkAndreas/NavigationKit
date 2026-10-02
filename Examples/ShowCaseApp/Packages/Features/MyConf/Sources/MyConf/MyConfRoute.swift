import NavigationKit

public enum MyConfRoute: Route {
    case overview
    case participationStatement
    case dashboard
    case savedSessions
    case scanQRCode

    public var presentation: PresentationStyle? {
        if case .scanQRCode = self { .sheet } else { nil }
    }
}

// MARK: - Swag redemption

/// Redeeming a reward. Callers start the flow, never its screens: `navigator.flow(SwagRedemption())`.
public struct SwagRedemption: Flow {
    public init() {}

    public enum Step: Hashable, Codable, Sendable {
        case swagSelection
        case shippingAddressEntry
        case billingDetails
        case paymentMethod
        case summary
    }

    public var start: Step { .swagSelection }
}

// MARK: - Hackathon registration

/// Registering a hackathon project. The proof step is a separate, reusable flow (``ProofFlow``).
public struct HackathonRegistration: Flow {
    public init() {}

    public enum Step: Hashable, Codable, Sendable {
        case teamSizeSelection
        case projectCategorySelection
        case teamDetailsForm
        case summary(Proof)
    }

    public var start: Step { .teamSizeSelection }
}
