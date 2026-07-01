import Foundation

public enum SwagRedemptionRoute: Hashable {
    case swagSelection
    case shippingAddressEntry
    case billingDetails
    case paymentMethod
    case summary
}

public enum ProofRequirement: String, Hashable {
    case documentOnly = "Document Only"
    case serviceProviderOnly = "Service Provider Only"
    case both = "Both"
}

public enum HackathonRegistrationRoute: Hashable {
    case teamSizeSelection
    case projectCategorySelection
    case teamDetailsForm
    case projectUpload(ProofRequirement)
    case repositoryLinkEntry(ProofRequirement)
    case verificationSelection
    case summary
}

public enum MyConfRoute: Hashable {
    case overview
    case participationStatement
    case dashboard
    case savedSessions
    case scanQRCode
    case swagRedemption(SwagRedemptionRoute)
    case hackathonRegistration(HackathonRegistrationRoute)
}
