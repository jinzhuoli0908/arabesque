import ArabesqueCore
import ArabesqueSystem
import Cocoa
import InputMethodKit

/// IMK shell: converts NSEvents for the engine and applies its actions. No rules here.
@objc(ArabesqueInputController)
final class ArabesqueInputController: IMKInputController {
    private var engine = Engine()

    override func recognizedEvents(_ sender: Any!) -> Int {
        let mask: NSEvent.EventTypeMask = [.keyDown, .flagsChanged, .leftMouseDown, .rightMouseDown, .otherMouseDown]
        return Int(mask.rawValue)
    }

    override func handle(_ event: NSEvent!, client sender: Any!) -> Bool {
        guard let event, let client = sender as? IMKTextInput else { return false }
        switch event.type {
        case .flagsChanged:
            let flags = event.modifierFlags
            let result = engine.flagsChanged(option: flags.contains(.option), shift: flags.contains(.shift))
            apply(result, to: client)
            return false  // modifier keys always go back to the app
        case .keyDown:
            let flags = event.modifierFlags
            let keyEvent = KeyEvent(
                key: KeyCodeMap.key(for: event.keyCode),
                shift: flags.contains(.shift),
                capsLock: flags.contains(.capsLock),
                option: flags.contains(.option),
                commandOrControl: flags.contains(.command) || flags.contains(.control),
                isRepeat: event.isARepeat
            )
            let result = engine.handle(keyEvent)
            apply(result, to: client)
            return !result.passThrough
        case .leftMouseDown, .rightMouseDown, .otherMouseDown:
            apply(engine.interrupt(), to: client)
            return false
        default:
            return false
        }
    }

    override func activateServer(_ sender: Any!) {
        super.activateServer(sender)
        (sender as? IMKTextInput)?.overrideKeyboard(withKeyboardNamed: InputSources.baseLayoutID())
        let optionDown = CGEventSource.flagsState(.combinedSessionState).contains(.maskAlternate)
        _ = engine.optionChanged(isDown: optionDown)
    }

    override func deactivateServer(_ sender: Any!) {
        if let client = sender as? IMKTextInput {
            apply(engine.interrupt(), to: client)
        }
        super.deactivateServer(sender)
    }

    override func commitComposition(_ sender: Any!) {
        if let client = sender as? IMKTextInput {
            apply(engine.interrupt(), to: client)
        }
    }

    private func apply(_ result: EngineResult, to client: IMKTextInput) {
        let noReplacement = NSRange(location: NSNotFound, length: 0)
        for action in result.actions {
            switch action {
            case .insert(let text):
                client.insertText(text, replacementRange: noReplacement)
            case .setMarked(let text):
                let caret = NSRange(location: (text as NSString).length, length: 0)
                client.setMarkedText(text, selectionRange: caret, replacementRange: noReplacement)
            case .clearMarked:
                client.setMarkedText("", selectionRange: NSRange(location: 0, length: 0), replacementRange: noReplacement)
            }
        }
    }
}
