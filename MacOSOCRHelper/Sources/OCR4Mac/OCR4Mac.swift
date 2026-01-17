import SwiftUI
import AppKit

// No "App" struct for NSApplicationDelegate based apps usually, but we can use NSApplicationMain
// or just a manual main entry point. Since we are using an executable package, manual main is best.

@main
enum OCR4MacMain {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.accessory) // Hide dock icon, status bar only
        _ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
    }
}

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem!
    var lastResultItem: NSMenuItem!
    var coordinator: AppCoordinator!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize coordinator
        coordinator = AppCoordinator()
        // Capture [weak self] to avoid retain cycle and call updateLastResult
        coordinator.onResultUpdate = { [weak self] text in
            self?.updateLastResult(text)
        }
        coordinator.start()

        // Setup Menu Bar
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusBarItem.button {
            button.image = NSImage(systemSymbolName: "text.viewfinder", accessibilityDescription: "OCR Helper")
            button.action = #selector(togglePopover(_:))
            button.target = self
        }

        // Build Menu
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Capture Area", action: #selector(captureArea), keyEquivalent: "A"))

        menu.addItem(NSMenuItem.separator())

        lastResultItem = NSMenuItem(title: "No recent result", action: nil, keyEquivalent: "")
        lastResultItem.isEnabled = false
        menu.addItem(lastResultItem)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))

        statusBarItem.menu = menu
    }

    func updateLastResult(_ text: String) {
        let preview = text.prefix(20).replacingOccurrences(of: "\n", with: " ")
        lastResultItem.title = "Last: \(preview)..."
    }

    @objc func captureArea() {
        coordinator.startCapture()
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        // If we had a popover for settings/history, we'd toggle it here.
        // For now, click just shows the menu (default behavior if .menu is set)
        // If we want a custom view on click AND a right-click menu, it's more complex.
        // Standard macOS menu bar apps often just show the menu on click.
        // The PRD mentions "Status Bar Menu: Quick start/settings/quit".
        // So a standard menu is sufficient.
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}

// Coordinator class to handle logic bridging SwiftUI and AppKit
@MainActor
class AppCoordinator: NSObject, GlobalHotkeyDelegate, CaptureOverlayDelegate {
    var onResultUpdate: ((String) -> Void)?
    private lazy var overlayWindow: CaptureOverlayWindow = {
        let overlay = CaptureOverlayWindow()
        overlay.captureDelegate = self
        return overlay
    }()

    private var resultWindow: NSWindow?

    func start() {
        GlobalHotkeyManager.shared.delegate = self
        GlobalHotkeyManager.shared.registerHotKey()
    }

    func hotkeyPressed() {
        print("Hotkey pressed!")
        startCapture()
    }

    func startCapture() {
        // Show overlay
        overlayWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    // MARK: - CaptureOverlayDelegate
    func didSelectRect(_ rect: CGRect) {
        print("Selected rect: \(rect)")

        // Hide overlay instead of closing/releasing
        overlayWindow.orderOut(nil)

        // Capture screen
        guard let cgImage = ScreenCaptureService.shared.captureScreen(rect: rect) else {
            print("Failed to capture screen")
            return
        }

        // Perform OCR
        Task {
            do {
                let text = try await OCRService.shared.recognizeText(from: cgImage)
                print("OCR Result: \(text)")
                ClipboardService.shared.copyToClipboard(text)
                self.onResultUpdate?(text)

                // Show result window
                showResultWindow(with: text)
            } catch {
                print("OCR Error: \(error)")
            }
        }
    }

    func didCancel() {
        print("Capture cancelled")
        overlayWindow.orderOut(nil)
    }

    private func showResultWindow(with text: String) {
        if resultWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 300, height: 200),
                styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            window.title = "OCR Result"
            window.center()
            window.isReleasedWhenClosed = false
            window.level = .floating
            self.resultWindow = window
        }

        let contentView = ResultView(text: .constant(text)) { [weak self] in
            self?.resultWindow?.close()
        }

        resultWindow?.contentView = NSHostingView(rootView: contentView)
        resultWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
