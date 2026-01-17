import Foundation
import ApplicationServices
import CoreGraphics

// Simulate Cmd+Option+A
func simulateHotkey() {
    print("Simulating Cmd+Option+A...")
    let src = CGEventSource(stateID: .hidSystemState)

    let cmd = CGEvent(keyboardEventSource: src, virtualKey: 0x37, keyDown: true) // Cmd
    let opt = CGEvent(keyboardEventSource: src, virtualKey: 0x3A, keyDown: true) // Option
    let a = CGEvent(keyboardEventSource: src, virtualKey: 0x00, keyDown: true)   // A

    cmd?.flags = .maskCommand
    opt?.flags = [.maskCommand, .maskAlternate]
    a?.flags = [.maskCommand, .maskAlternate]

    cmd?.post(tap: .cghidEventTap)
    opt?.post(tap: .cghidEventTap)
    a?.post(tap: .cghidEventTap)

    a?.type = .keyUp
    a?.post(tap: .cghidEventTap)
    opt?.type = .keyUp
    opt?.post(tap: .cghidEventTap)
    cmd?.type = .keyUp
    cmd?.post(tap: .cghidEventTap)
}

// Simulate Mouse Drag
func simulateMouseDrag() {
    print("Simulating Mouse Drag...")
    let start = CGPoint(x: 300, y: 300)
    let end = CGPoint(x: 600, y: 400)

    let move = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: start, mouseButton: .left)
    move?.post(tap: .cghidEventTap)
    usleep(500000)

    let down = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: start, mouseButton: .left)
    down?.post(tap: .cghidEventTap)
    usleep(500000)

    let drag = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDragged, mouseCursorPosition: end, mouseButton: .left)
    drag?.post(tap: .cghidEventTap)
    usleep(500000)

    let up = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: end, mouseButton: .left)
    up?.post(tap: .cghidEventTap)
}

print("Waiting 5 seconds for app to stabilize...")
sleep(5)

simulateHotkey()

print("Waiting 2 seconds for overlay...")
sleep(2)

simulateMouseDrag()

print("Waiting 5 seconds for OCR result...")
sleep(5)

print("Test complete.")
