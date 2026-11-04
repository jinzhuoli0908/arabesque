/// What the input method should do to the text field.
public enum Action: Equatable, Sendable {
    /// Insert text. Replaces the marked text if there is any; this is how marked text is committed.
    case insert(String)
    /// Show, or replace, the underlined text that is not committed yet.
    case setMarked(String)
    /// Remove the marked text without inserting anything.
    case clearMarked
}

public struct EngineResult: Equatable, Sendable {
    public var actions: [Action]
    /// true: the app should also handle the original event, after the actions are applied.
    public var passThrough: Bool

    public init(actions: [Action] = [], passThrough: Bool) {
        self.actions = actions
        self.passThrough = passThrough
    }
}

/// The Arabesque state machine (RULES.md, Rules). The IMK shell feeds it events.
public struct Engine: Sendable {
    enum Marked: Equatable, Sendable {
        /// a/e/i/o/u/y waiting for a possible second key (R2).
        case pending(letter: Character, upper: Bool)
        /// A finished Arabesque character, still marked until ⌥ is released or the next key (R9).
        case held(String)
        /// ⌥; waiting for i/e/y/u (R6, R7).
        case deadKey
    }

    public private(set) var optionHeld = false
    /// The current ⌥ hold has already produced an Arabesque character (R1).
    public private(set) var holdSpent = false
    /// Shift as last seen, from its own press and release and from every keyDown (RULES.md, Capitals).
    public private(set) var shiftHeld = false
    /// Shift went down and no key has come since: releasing it now is a pure tap (RULES.md, Capitals).
    private var shiftTapPending = false
    /// A pure Shift tap during this ⌥ hold: the next key is treated as shifted (RULES.md, Capitals).
    public private(set) var shiftArmed = false
    private var marked: Marked?

    public init() {}

    /// The marked text currently shown, if any.
    public var markedText: String? {
        switch marked {
        case .pending(let letter, let upper): return Engine.single(letter, upper: upper)
        case .held(let text): return text
        case .deadKey: return CoreTable.deadKeyDisplay
        case nil: return nil
        }
    }

    // MARK: - Events

    public mutating func optionChanged(isDown: Bool) -> EngineResult {
        if isDown {
            if !optionHeld {
                optionHeld = true
                holdSpent = false
                shiftArmed = false
            }
            return EngineResult(passThrough: true)
        }
        guard optionHeld else { return EngineResult(passThrough: true) }
        let actions = commitMarked()
        optionHeld = false
        holdSpent = false
        shiftArmed = false
        shiftTapPending = false
        return EngineResult(actions: actions, passThrough: true)
    }

    /// RULES.md, Capitals: Shift can simply be tapped while ⌥ is held. A press capitalizes the marked character
    /// at once (⌥(e ⇧) = É); a pure tap with nothing marked makes the next key shifted (⌥(⇧ e) = É).
    public mutating func shiftChanged(isDown: Bool) -> EngineResult {
        let pressed = isDown && !shiftHeld
        let released = !isDown && shiftHeld
        shiftHeld = isDown
        if released {
            if shiftTapPending && optionHeld { shiftArmed = true }
            shiftTapPending = false
            return EngineResult(passThrough: true)
        }
        guard pressed else { return EngineResult(passThrough: true) }
        switch marked {
        case .pending(letter: let letter, upper: let upper):
            shiftTapPending = false  // this press belongs to the marked character
            guard !upper else { return EngineResult(passThrough: true) }
            marked = .pending(letter: letter, upper: true)
            return EngineResult(actions: [.setMarked(Engine.single(letter, upper: true))], passThrough: true)
        case .held(let text):
            shiftTapPending = false
            let capital = Casing.upper(text: text)
            guard capital != text else { return EngineResult(passThrough: true) }
            marked = .held(capital)
            return EngineResult(actions: [.setMarked(capital)], passThrough: true)
        case .deadKey, nil:
            shiftTapPending = true  // a release before any key arms the next key
            return EngineResult(passThrough: true)
        }
    }

    /// Handles a flagsChanged event, given whether ⌥ and Shift are down now. ⌥ is handled before Shift: if one
    /// event releases ⌥ and presses Shift, the marked character is committed without the Shift press capitalizing
    /// it. A Shift press while ⌥ stays down capitalizes the marked character instead.
    public mutating func flagsChanged(option: Bool, shift: Bool) -> EngineResult {
        var actions = optionChanged(isDown: option).actions
        actions += shiftChanged(isDown: shift).actions
        return EngineResult(actions: actions, passThrough: true)
    }

    /// R13: click, app switch, input source switch, or the system asking to commit.
    public mutating func interrupt() -> EngineResult {
        var actions = commitMarked()
        if marked == .deadKey {
            marked = nil
            actions.append(.clearMarked)
        }
        shiftArmed = false
        shiftTapPending = false
        return EngineResult(actions: actions, passThrough: true)
    }

    public mutating func handle(_ incoming: KeyEvent) -> EngineResult {
        var event = incoming  // the arm may set event.shift; such a key is always consumed by Arabesque, never passed to the app
        // Trust the event's own ⌥ flag over our bookkeeping.
        var actions: [Action] = []
        if event.option != optionHeld {
            actions += optionChanged(isDown: event.option).actions
        }
        shiftHeld = event.shift  // a keyDown also tells us whether Shift is down (RULES.md, Capitals)
        shiftTapPending = false  // a key while Shift is down makes it a chord, not a tap (RULES.md, Capitals)
        if shiftArmed, !event.isRepeat {
            shiftArmed = false
            if case .character = event.key, !event.commandOrControl {
                event.shift = true  // the tapped Shift applies to this key (RULES.md, Capitals)
            }
        }

        // R12: ⌘/⌃ shortcuts commit first, then go to the app untouched.
        if event.commandOrControl {
            return EngineResult(actions: actions + interrupt().actions, passThrough: true)
        }

        // R14: ignore autorepeat of scheme keys while ⌥ is held.
        if event.isRepeat, event.option, case .character(let c) = event.key, CoreTable.schemeKeys.contains(c) {
            return EngineResult(actions: actions, passThrough: false)
        }

        if marked == .deadKey, let result = handleDeadKey(event, actions: &actions) {
            return result
        }

        guard event.option else {
            return EngineResult(actions: actions, passThrough: true)
        }

        switch event.key {
        case .function(let function):
            return handleFunctionKey(function, actions: actions)
        case .character(let c):
            return handleOptionCharacter(c, event: event, actions: actions)
        }
    }

    // MARK: - Rules

    /// R6, R7 and R10 while the dead key waits. Returns nil when the key should then be handled normally.
    private mutating func handleDeadKey(_ event: KeyEvent, actions: inout [Action]) -> EngineResult? {
        if case .function(let function) = event.key, function == .delete || function == .escape {
            marked = nil
            return EngineResult(actions: actions + [.clearMarked], passThrough: false)
        }
        if case .character(let c) = event.key, let trema = CoreTable.trema[c] {
            let text = Casing.apply(trema, upper: event.shift || event.capsLock)
            if event.option {
                marked = .held(text)
                holdSpent = true
                return EngineResult(actions: actions + [.setMarked(text)], passThrough: false)
            }
            marked = nil
            return EngineResult(actions: actions + [.insert(text)], passThrough: false)
        }
        // R7: cancel quietly. A character key is then typed plain whether or not ⌥ is held (R6);
        // with ⌥ held the cancelled dead key uses up the hold, so the rest of it is plain too (R1).
        marked = nil
        actions.append(.clearMarked)
        if event.option, case .character = event.key {
            holdSpent = true
        }
        return nil
    }

    /// R10 (⌫, Esc) and R11 (other function keys) while ⌥ is held.
    private mutating func handleFunctionKey(_ function: FunctionKey, actions: [Action]) -> EngineResult {
        if function == .delete || function == .escape {
            switch marked {
            case .pending:
                marked = nil
                return EngineResult(actions: actions + [.clearMarked], passThrough: false)
            case .held:
                marked = nil
                holdSpent = false
                return EngineResult(actions: actions + [.clearMarked], passThrough: false)
            case .deadKey, nil:
                return EngineResult(actions: actions, passThrough: true)
            }
        }
        return EngineResult(actions: actions + commitMarked(), passThrough: true)
    }

    /// R1–R4 and R8 for a printable key pressed while ⌥ is held.
    private mutating func handleOptionCharacter(_ c: Character, event: KeyEvent, actions: [Action]) -> EngineResult {
        var actions = actions
        let upper = event.shift || event.capsLock
        if case .held = marked {
            actions += commitMarked()
        }
        if case .pending(let first, let firstUpper) = marked {
            let keys = String([first, c])
            if let combined = CoreTable.pairs[keys] ?? CoreTable.postfixTrema[keys] {
                let text = Casing.apply(combined, upper: firstUpper || upper)
                marked = .held(text)
                holdSpent = true
                return EngineResult(actions: actions + [.setMarked(text)], passThrough: false)
            }
            actions += commitMarked()
        }
        if holdSpent {
            let plain = PlainKeys.character(for: c, shift: event.shift, capsLock: event.capsLock)
            return EngineResult(actions: actions + [.insert(plain)], passThrough: false)
        }
        if CoreTable.pairStarters.contains(c) {
            marked = .pending(letter: c, upper: upper)
            return EngineResult(actions: actions + [.setMarked(Engine.single(c, upper: upper))], passThrough: false)
        }
        if let single = CoreTable.singles[c] {
            let text = Casing.apply(single, upper: upper)
            marked = .held(text)
            holdSpent = true
            return EngineResult(actions: actions + [.setMarked(text)], passThrough: false)
        }
        if c == CoreTable.deadKey {
            marked = .deadKey
            return EngineResult(actions: actions + [.setMarked(CoreTable.deadKeyDisplay)], passThrough: false)
        }
        return EngineResult(actions: actions + [.insert(Engine.symbolOrPlain(c, event: event))], passThrough: false)
    }

    /// Commits pending or held marked text (R9). A waiting dead key is left alone.
    private mutating func commitMarked() -> [Action] {
        switch marked {
        case .pending(let letter, let upper):
            marked = nil
            if CoreTable.singles[letter] != nil {
                holdSpent = true  // a letter with no single (i, y) is typed plain and does not use up the hold (R3)
            }
            return [.insert(Engine.single(letter, upper: upper))]
        case .held(let text):
            marked = nil
            return [.insert(text)]
        case .deadKey, nil:
            return []
        }
    }

    // MARK: - Helpers

    /// What a waiting letter becomes on its own: its core single, or a plain i or y (R3).
    static func single(_ letter: Character, upper: Bool) -> String {
        if let single = CoreTable.singles[letter] {
            return Casing.apply(single, upper: upper)
        }
        return upper ? letter.uppercased() : String(letter)
    }

    /// R4: letters, space, ' and ` are typed plain; other digits and punctuation give ABC's ⌥ symbols.
    static func symbolOrPlain(_ c: Character, event: KeyEvent) -> String {
        let table = event.shift ? SymbolTable.optionShift : SymbolTable.option
        if let symbol = table[c] {
            return String(symbol)
        }
        return PlainKeys.character(for: c, shift: event.shift, capsLock: event.capsLock)
    }
}
