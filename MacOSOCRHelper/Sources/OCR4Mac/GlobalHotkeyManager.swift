import Cocoa
import Carbon

@MainActor
protocol GlobalHotkeyDelegate: AnyObject {
    func hotkeyPressed()
}

@MainActor
class GlobalHotkeyManager {
    static let shared = GlobalHotkeyManager()
    weak var delegate: GlobalHotkeyDelegate?

    private var eventHandler: EventHandlerRef?
    private var hotKeyRef: EventHotKeyRef?

    private init() {} // Private init for singleton

    // Default: Cmd + Option + A
    // Cmd = cmdKey (0x0100)
    // Option = optionKey (0x0800)
    // A = kVK_ANSI_A (0x00)

    func registerHotKey() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        // Install handler
        let observer = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        InstallEventHandler(GetApplicationEventTarget(), { (handler, event, userData) -> OSStatus in
            guard let userData = userData else { return noErr }
            let manager = Unmanaged<GlobalHotkeyManager>.fromOpaque(userData).takeUnretainedValue()
            manager.delegate?.hotkeyPressed()
            return noErr
        }, 1, &eventType, observer, &eventHandler)

        // Register Hotkey (Cmd + Option + A)
        let hotKeyID = EventHotKeyID(signature: OSType(0x4F435220), id: 1) // 'OCR '

        // kVK_ANSI_A = 0x00
        var gMyHotKeyRef: EventHotKeyRef?
        RegisterEventHotKey(UInt32(kVK_ANSI_A),
                           UInt32(cmdKey | optionKey),
                           hotKeyID,
                           GetApplicationEventTarget(),
                           0,
                           &gMyHotKeyRef)

        self.hotKeyRef = gMyHotKeyRef
        print("Global Hotkey (Cmd+Opt+A) registered")
    }

    func unregisterHotKey() {
        if let handler = eventHandler {
            RemoveEventHandler(handler)
        }
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
        }
    }
}
