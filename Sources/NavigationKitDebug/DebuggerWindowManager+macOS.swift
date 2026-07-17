#if os(macOS)
import NavigationKit

import AppKit
import SwiftUI

/// Hosts the floating debugger on macOS as a panel attached to the app's window.
///
/// The iOS debugger covers the screen with a click-through window and hit-tests the button's frame
/// out of it. macOS has no equivalent of that window, so the button gets a panel sized to itself
/// instead: everything outside it passes through because there is no window there to intercept.
/// The panel is a child of the app's window, so it follows the window and stays above the sheets it
/// presents. The graph opens in its own window rather than a sheet, which is the macOS idiom for an
/// inspector and avoids attaching a sheet to a button-sized panel.
@MainActor
@Observable
class DebuggerWindowManager {
    private var buttonPanel: NSPanel?
    private var graphWindow: NSWindow?

    private let buttonSize: CGFloat = 44
    private let margin: CGFloat = 24

    func show(navigator: RootNavigator) {
        guard let host = NSApp.keyWindow ?? NSApp.windows.first(where: \.isVisible) else {
            // No window yet — the app may still be launching, so try again shortly.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.show(navigator: navigator)
            }
            return
        }

        guard buttonPanel == nil else { return }

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: buttonSize, height: buttonSize),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        // Follow the app in and out of the foreground rather than hovering over other apps.
        panel.hidesOnDeactivate = true

        let container = DebuggerButtonHostView(
            frame: NSRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        )
        container.onClick = { [weak self] in
            self?.toggleGraphWindow(navigator: navigator)
        }

        let hosting = NSHostingView(rootView: DebuggerButtonView())
        hosting.frame = container.bounds
        hosting.autoresizingMask = [.width, .height]
        container.addSubview(hosting)
        panel.contentView = container

        // Bottom-trailing corner of the host window, mirroring the iOS button's resting position.
        panel.setFrameOrigin(
            CGPoint(
                x: host.frame.maxX - buttonSize - margin,
                y: host.frame.minY + margin
            )
        )

        host.addChildWindow(panel, ordered: .above)
        // `addChildWindow` resets the child to the parent's level, which leaves the button behind
        // any sheet the app presents — so raise it afterwards, not before.
        panel.level = .floating
        buttonPanel = panel
    }

    private func toggleGraphWindow(navigator: RootNavigator) {
        if let graphWindow {
            graphWindow.makeKeyAndOrderFront(nil)
            return
        }

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 520, height: 640),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Navigation Graph"
        window.contentView = NSHostingView(rootView: NavigationGraphView(navigator: navigator))
        // Keep the window alive after a close so reopening reuses it.
        window.isReleasedWhenClosed = false
        window.center()
        window.makeKeyAndOrderFront(nil)
        graphWindow = window
    }
}

/// The debugger button's visual, kept free of gestures — `DebuggerButtonHostView` handles input.
private struct DebuggerButtonView: View {
    var body: some View {
        Image(systemName: "ladybug.fill")
            .font(.title2)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.red)
            .clipShape(Circle())
            .shadow(radius: 4, y: 2)
    }
}

/// Distinguishes a click on the debugger button from a drag of its panel.
///
/// Dragging is tracked in screen coordinates via `NSEvent.mouseLocation`: the panel moves during the
/// drag, so any window-relative measurement would shift under the cursor and feed back into itself.
private final class DebuggerButtonHostView: NSView {
    var onClick: (() -> Void)?

    /// Claim every event in the panel so the hosting view underneath never swallows a drag.
    override func hitTest(_ point: NSPoint) -> NSView? { self }

    override func mouseDown(with event: NSEvent) {
        guard let window else { return }

        let startOrigin = window.frame.origin
        let startMouse = NSEvent.mouseLocation
        var isDragging = false

        while let next = window.nextEvent(matching: [.leftMouseDragged, .leftMouseUp]) {
            if next.type == .leftMouseUp { break }

            let mouse = NSEvent.mouseLocation
            let dx = mouse.x - startMouse.x
            let dy = mouse.y - startMouse.y

            // Only start moving past a small threshold, so a click with slight jitter stays a click.
            if !isDragging, hypot(dx, dy) > 3 { isDragging = true }
            if isDragging {
                window.setFrameOrigin(CGPoint(x: startOrigin.x + dx, y: startOrigin.y + dy))
            }
        }

        if !isDragging { onClick?() }
    }
}
#endif
