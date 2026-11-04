import Foundation
@testable import ArabesqueCore

/// A fake text field that applies engine actions the way an IMK client does,
/// and types pass-through printable keys the way the app would with the base layout.
struct FakeTextField {
    var text = ""
    var marked: String?
    var insertions: [String] = []
    var passedToApp: [String] = []

    mutating func apply(_ result: EngineResult, for event: KeyEvent? = nil) {
        for action in result.actions {
            switch action {
            case .insert(let string):
                text += string
                insertions.append(string)
                marked = nil
            case .setMarked(let string):
                marked = string.isEmpty ? nil : string
            case .clearMarked:
                marked = nil
            }
        }
        guard result.passThrough, let event else { return }
        if case .character(let c) = event.key, !event.option, !event.commandOrControl {
            let typed = PlainKeys.character(for: c, shift: event.shift, capsLock: event.capsLock)
            text += typed
            insertions.append(typed)
        } else {
            passedToApp.append(Typing.describe(event))
        }
    }
}

/// Types scripts written in the notation of RULES.md, Examples:
/// `⌥( … )` one hold · `⇧x` Shift (pressed before x, released after) · `⇧` alone: Shift pressed and released ·
/// `x*` autorepeat · `⌘x` command · `␣` space · `⌫` delete · `⎋` escape · `⏎` return · `CLICK` interrupt.
enum Typing {
    static func type(_ script: String, capsLock: Bool = false) -> (field: FakeTextField, engine: Engine) {
        var engine = Engine()
        var field = FakeTextField()
        var option = false
        for token in tokens(script) {
            switch token {
            case "⌥(":
                option = true
                field.apply(engine.optionChanged(isDown: true))
            case ")":
                option = false
                field.apply(engine.optionChanged(isDown: false))
            case "CLICK":
                field.apply(engine.interrupt())
            case "⇧":  // Shift pressed and released on its own (RULES.md, Capitals)
                field.apply(engine.shiftChanged(isDown: true))
                field.apply(engine.shiftChanged(isDown: false))
            default:
                let event = keyEvent(token, option: option, capsLock: capsLock)
                if event.shift { field.apply(engine.shiftChanged(isDown: true)) }  // Shift goes down before its key
                field.apply(engine.handle(event), for: event)
                if event.shift { field.apply(engine.shiftChanged(isDown: false)) }
            }
        }
        return (field, engine)
    }

    static func tokens(_ script: String) -> [String] {
        script.replacingOccurrences(of: "⌥(", with: " ⌥( ")
            .replacingOccurrences(of: ")", with: " ) ")
            .split(separator: " ")
            .map(String.init)
    }

    static func keyEvent(_ token: String, option: Bool, capsLock: Bool) -> KeyEvent {
        var name = Substring(token)
        var command = false
        var shift = false
        var isRepeat = false
        if name.hasPrefix("⌘") { command = true; name = name.dropFirst() }
        if name.hasPrefix("⇧") { shift = true; name = name.dropFirst() }
        if name.count > 1, name.hasSuffix("*") { isRepeat = true; name = name.dropLast() }
        let key: Key
        switch name {
        case "⌫": key = .function(.delete)
        case "⎋": key = .function(.escape)
        case "⏎": key = .function(.other)
        case "␣": key = .character(" ")
        default: key = .character(name.first!)
        }
        return KeyEvent(key: key, shift: shift, capsLock: capsLock, option: option,
                        commandOrControl: command, isRepeat: isRepeat)
    }

    static func describe(_ event: KeyEvent) -> String {
        let prefix = event.commandOrControl ? "⌘" : (event.option ? "⌥" : "")
        switch event.key {
        case .character(let c): return prefix + String(c)
        case .function(.delete): return prefix + "⌫"
        case .function(.escape): return prefix + "⎋"
        case .function(.other): return prefix + "⏎"
        }
    }
}
