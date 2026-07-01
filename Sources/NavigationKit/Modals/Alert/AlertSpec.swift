import SwiftUI

/// A declarative specification for a standard system alert.
///
/// `AlertSpec` describes the content and available actions for an alert dialog.
/// This allows `NavigationKit` to manage alerts as state rather than directly binding views.
public struct AlertSpec: Identifiable {
    /// A unique identifier for this alert instance.
    public let id = UUID()
    public var title: String
    public var message: String?
    public var buttons: [Button]

    public struct Button: Identifiable {
        public let id = UUID()
        public var title: String; public var role: ButtonRole?; public var action: () -> Void
        public init(_ t: String, role: ButtonRole? = nil, action: @escaping () -> Void = {}) {
            title = t; self.role = role; self.action = action
        }
    }

    public init(title: String, message: String? = nil, buttons: [Button]) {
        self.title = title; self.message = message; self.buttons = buttons
    }
}
