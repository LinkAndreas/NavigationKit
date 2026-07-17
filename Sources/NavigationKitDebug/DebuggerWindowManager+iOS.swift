#if os(iOS)
import NavigationKit

import SwiftUI
import UIKit

@MainActor
@Observable
class DebuggerWindowManager {
    var buttonFrame: CGRect = .zero
    private var window: PassthroughWindow?

    func show(navigator: RootNavigator) {
        guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
            // Scene might not be active yet, try again shortly
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.show(navigator: navigator)
            }
            return
        }
        
        if window == nil {
            let passthroughWindow = PassthroughWindow(windowScene: windowScene)
            passthroughWindow.manager = self
            let hostingController = UIHostingController(rootView: FloatingDebuggerView(navigator: navigator, manager: self))
            hostingController.view.backgroundColor = .clear
            passthroughWindow.rootViewController = hostingController
            passthroughWindow.windowLevel = .alert + 1
            passthroughWindow.isHidden = false
            self.window = passthroughWindow
        }
    }
}
#endif
