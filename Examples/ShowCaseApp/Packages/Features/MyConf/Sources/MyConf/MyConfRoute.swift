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

/// Redeeming a reward. Callers start the flow, not its first screen: `nav.flow(SwagRedemption())`.
public struct SwagRedemption: Flow {
    public init() {}
    public var start: SwagRedemptionRoute { .swagSelection }
}

public enum SwagRedemptionRoute: Route {
    case swagSelection
    case shippingAddressEntry
    case billingDetails
    case paymentMethod
    case summary
}

// MARK: - Hackathon registration

/// Registering a hackathon project. The proof step is a separate, reusable flow (``ProofFlow``).
public struct HackathonRegistration: Flow {
    public init() {}
    public var start: HackathonRegistrationRoute { .teamSizeSelection }
}

public enum HackathonRegistrationRoute: Route {
    case teamSizeSelection
    case projectCategorySelection
    case teamDetailsForm
    case summary(Proof)
}
