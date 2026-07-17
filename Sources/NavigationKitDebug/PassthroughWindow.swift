#if os(iOS)
import NavigationKit

import UIKit
import SwiftUI

class PassthroughWindow: UIWindow {
    weak var manager: DebuggerWindowManager?

    override var canBecomeKey: Bool { false }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        
        // Let the root view handle the touch only if it falls within the button's exact frame
        if let manager = manager, manager.buttonFrame.contains(point) {
            return view
        }
        
        // Also allow interaction with the debug sheet if it's presented.
        // Sheets are presented in a different window hierarchy, but just in case,
        // if the hit view is NOT the root hosting view, it might be a presented view.
        if let root = rootViewController?.view, view != root, view != self {
            return view
        }
        
        return nil
    }
}
#endif
