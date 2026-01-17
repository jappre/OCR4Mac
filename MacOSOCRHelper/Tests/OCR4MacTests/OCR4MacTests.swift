import XCTest
import CoreGraphics
import CoreText
@testable import OCR4Mac

final class OCR4MacTests: XCTestCase {

    // Helper to create an image with text
    func createImageWithText(_ text: String, width: Int = 400, height: Int = 100) -> CGImage? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else { return nil }

        // Fill white background
        context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        // Draw text
        context.setTextDrawingMode(.fill)
        context.setFillColor(CGColor(red: 0, green: 0, blue: 0, alpha: 1))

        let attributedString = NSAttributedString(
            string: text,
            attributes: [
                .font: CTFontCreateWithName("Helvetica" as CFString, 48, nil),
                .foregroundColor: CGColor(red: 0, green: 0, blue: 0, alpha: 1)
            ]
        )

        let line = CTLineCreateWithAttributedString(attributedString)
        context.textPosition = CGPoint(x: 20, y: 30)
        CTLineDraw(line, context)

        return context.makeImage()
    }

    func testOCRService() async throws {
        let text = "Hello World"
        guard let image = createImageWithText(text) else {
            XCTFail("Could not create image")
            return
        }

        let result = try await OCRService.shared.recognizeText(from: image)
        print("Test recognized: \(result)")

        // Vision OCR might return slightly different results depending on font/rendering,
        // but it should contain the words.
        XCTAssertTrue(result.contains("Hello"), "Result should contain 'Hello'")
        XCTAssertTrue(result.contains("World"), "Result should contain 'World'")
    }

    @MainActor
    func testClipboardService() {
        let text = "Test Clipboard"
        ClipboardService.shared.copyToClipboard(text)

        let pasteboard = NSPasteboard.general
        if let copied = pasteboard.string(forType: .string) {
            XCTAssertEqual(copied, text)
        } else {
            XCTFail("Clipboard should contain text")
        }
    }
}
