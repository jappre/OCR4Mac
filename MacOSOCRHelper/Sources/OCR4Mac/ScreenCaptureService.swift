import Foundation
import CoreGraphics

final class ScreenCaptureService: Sendable {
    static let shared = ScreenCaptureService()

    func captureScreen(rect: CGRect) -> CGImage? {
        return CGWindowListCreateImage(rect, .optionOnScreenBelowWindow, kCGNullWindowID, .bestResolution)
    }

    // Capture the entire screen
    func captureMainScreen() -> CGImage? {
        return CGWindowListCreateImage(CGRect.infinite, .optionOnScreenOnly, kCGNullWindowID, .bestResolution)
    }
}
