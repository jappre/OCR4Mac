import Cocoa
import SwiftUI

@MainActor
protocol CaptureOverlayDelegate: AnyObject {
    func didSelectRect(_ rect: CGRect)
    func didCancel()
}

class CaptureOverlayWindow: NSWindow {
    weak var captureDelegate: CaptureOverlayDelegate?
    private var startPoint: CGPoint?
    private var currentRect: CGRect?
    private var selectionLayer: CAShapeLayer?
    private var maskLayer: CAShapeLayer?

    init() {
        // Create a window that covers the main screen
        let screenRect = NSScreen.main?.frame ?? .zero
        super.init(contentRect: screenRect,
                   styleMask: [.borderless],
                   backing: .buffered,
                   defer: false)

        self.level = .screenSaver
        self.backgroundColor = NSColor.black.withAlphaComponent(0.3) // Dim background
        self.isOpaque = false
        self.hasShadow = false
        self.ignoresMouseEvents = false
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        setupLayers()
    }

    private func setupLayers() {
        guard let contentView = self.contentView else { return }
        contentView.wantsLayer = true

        selectionLayer = CAShapeLayer()
        selectionLayer?.fillColor = NSColor.clear.cgColor
        selectionLayer?.strokeColor = NSColor.white.cgColor
        selectionLayer?.lineWidth = 1.0
        selectionLayer?.lineDashPattern = [4, 4]
        contentView.layer?.addSublayer(selectionLayer!)
    }

    override var canBecomeKey: Bool {
        return true
    }

    override func mouseDown(with event: NSEvent) {
        startPoint = event.locationInWindow
        currentRect = CGRect(origin: startPoint!, size: .zero)
        updateSelectionVisual()
    }

    override func mouseDragged(with event: NSEvent) {
        guard let start = startPoint else { return }
        let current = event.locationInWindow

        let originX = min(start.x, current.x)
        let originY = min(start.y, current.y)
        let width = abs(current.x - start.x)
        let height = abs(current.y - start.y)

        currentRect = CGRect(x: originX, y: originY, width: width, height: height)
        updateSelectionVisual()
    }

    override func mouseUp(with event: NSEvent) {
        if let rect = currentRect, rect.width > 5 && rect.height > 5 {
            // ... (calc code) ...
            if let screen = NSScreen.main {
               let screenHeight = screen.frame.height
               let flippedY = screenHeight - (rect.origin.y + rect.height)
               let captureRect = CGRect(x: rect.origin.x, y: flippedY, width: rect.width, height: rect.height)

               // Delegate handles the logic and closing.
               // We do NOT close ourselves here to avoid conflicts or premature deallocation if the delegate releases us.
               captureDelegate?.didSelectRect(captureRect)
            } else {
               self.orderOut(nil)
            }
        } else {
            self.orderOut(nil)
        }
        startPoint = nil
        currentRect = nil
        updateSelectionVisual()
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // ESC
            captureDelegate?.didCancel()
            // Delegate calls orderOut, or we do it here if delegate doesn't.
            // But delegate implementation calls orderOut.
        }
    }

    private func updateSelectionVisual() {
        guard let layer = selectionLayer, let rect = currentRect else {
            selectionLayer?.path = nil
            return
        }
        let path = CGMutablePath()
        path.addRect(rect)
        layer.path = path
    }
}
