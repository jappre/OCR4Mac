import AppKit

@MainActor
class ClipboardService {
    static let shared = ClipboardService()

    func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}
