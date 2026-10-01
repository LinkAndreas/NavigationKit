import NavigationKit

public enum SwagRedemptionRoute: Hashable, Codable, Sendable {
    case swagSelection
    case shippingAddressEntry
    case billingDetails
    case paymentMethod
    case summary
}

public enum ProofRequirement: String, Hashable, Codable, Sendable {
    case documentOnly = "Document Only"
    case serviceProviderOnly = "Service Provider Only"
    case both = "Both"
}

public enum HackathonRegistrationRoute: Hashable, Codable, Sendable {
    case teamSizeSelection
    case projectCategorySelection
    case teamDetailsForm
    case projectUpload(ProofRequirement)
    case repositoryLinkEntry(ProofRequirement)
    case verificationSelection
    case summary
}

public enum MyConfRoute: Route {
    case overview
    case participationStatement
    case dashboard
    case savedSessions
    case scanQRCode
    case swagRedemption(SwagRedemptionRoute)
    case hackathonRegistration(HackathonRegistrationRoute)

    public var presentation: PresentationStyle? {
        if case .scanQRCode = self { .sheet } else { nil }
    }
}
