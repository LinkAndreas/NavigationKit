import NavigationKit

/// Collects proof of a project — a document, a repository link, or both — and returns it.
///
/// Owned by one team and reusable by any other: callers only need `navigator.flow(ProofFlow(…))`,
/// never the screens inside it.
public struct ProofFlow: Flow {
    public typealias Result = Proof

    public let requirement: ProofRequirement

    public init(requirement: ProofRequirement) {
        self.requirement = requirement
    }

    public enum Step: Hashable, Codable, Sendable {
        case verificationSelection
        case projectUpload(ProofRequirement)
        case repositoryLinkEntry(ProofRequirement)
    }

    public var start: Step {
        switch requirement {
        case .documentOnly, .both: .projectUpload(requirement)
        case .serviceProviderOnly: .repositoryLinkEntry(requirement)
        case .either: .verificationSelection
        }
    }
}

public enum ProofRequirement: String, Hashable, Codable, Sendable {
    case documentOnly = "Document Only"
    case serviceProviderOnly = "Service Provider Only"
    case either = "Document or Service Provider"
    case both = "Both"
}

public struct Proof: Hashable, Codable, Sendable, CustomStringConvertible {
    public var hasDocument = false
    public var hasRepositoryLink = false

    public var description: String {
        switch (hasDocument, hasRepositoryLink) {
        case (true, true): "Document + Repository"
        case (true, false): "Document"
        case (false, true): "Repository"
        case (false, false): "None"
        }
    }
}
