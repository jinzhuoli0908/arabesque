import Testing
@testable import ArabesqueCore

/// Rules whose effect is not visible in the final text alone: marked text, state, robustness.
@Suite("Engine rules")
struct EngineRuleTests {
    @Test func holdingOptionAloneShowsNothing() {  // R5
        let field = Typing.type("⌥(").field
        #expect(field.text.isEmpty)
        #expect(field.marked == nil)
    }

    @Test func pendingLetterIsShownMarkedAndReplacedByThePair() {  // R2, R9
        #expect(Typing.type("⌥(a").field.marked == "ä")
        #expect(Typing.type("⌥(a s").field.marked == "â")
        #expect(Typing.type("⌥(a s").field.text.isEmpty)
        #expect(Typing.type("⌥(a s)").field.text == "â")
    }

    @Test func immediateSinglesStayMarkedUntilRelease() {  // R9
        let field = Typing.type("⌥(c").field
        #expect(field.marked == "ç")
        #expect(field.text.isEmpty)
    }

    @Test func deadKeyShowsDiaeresisAndSurvivesOptionRelease() {  // R9
        #expect(Typing.type("⌥(;").field.marked == "¨")
        let (field, engine) = Typing.type("⌥(;)")
        #expect(field.marked == "¨")
        #expect(engine.markedText == "¨")
    }

    @Test func tremaTypedAfterReleaseIsCommittedAtOnce() {  // R9
        let field = Typing.type("⌥(;) e").field
        #expect(field.text == "ë")
        #expect(field.marked == nil)
    }

    @Test func deadKeyFollowUpIgnoresOption() {  // R6, R7
        for key in "abcdefghijklmnopqrstuvwxyz1-=[];,./" {
            let held = Typing.type("⌥( ; \(key) )").field.text
            let released = Typing.type("⌥( ; ) \(key)").field.text
            #expect(held == released, "key \(key): held \(held), released \(released)")
        }
    }

    @Test func cancelledDeadKeyUsesUpTheHold() {  // R7, R1
        #expect(Typing.type("⌥(; a s)").field.text == "as")
        #expect(Typing.type("⌥(;) ⌥(a s)").field.text == "as")
    }

    @Test func plainTypingPassesThrough() {  // R16
        let field = Typing.type("x ⇧y").field
        #expect(field.text == "xY")
    }

    @Test func nonSchemeKeysRepeatNormally() {  // R14
        #expect(Typing.type("⌥(- -*)").field.text == "––")
    }

    @Test func missedOptionReleaseCommitsBeforeAPlainKey() {  // trust the event's own ⌥ flag
        var engine = Engine()
        var field = FakeTextField()
        field.apply(engine.optionChanged(isDown: true))
        let a = KeyEvent(key: .character("a"), option: true)
        field.apply(engine.handle(a), for: a)
        let x = KeyEvent(key: .character("x"))  // ⌥ is up, but no flagsChanged arrived
        field.apply(engine.handle(x), for: x)
        #expect(field.text == "äx")
        #expect(engine.optionHeld == false)
    }

    @Test func missedOptionPressStartsAHold() {  // trust the event's own ⌥ flag
        var engine = Engine()
        var field = FakeTextField()
        let a = KeyEvent(key: .character("a"), option: true)  // no flagsChanged before it
        field.apply(engine.handle(a), for: a)
        #expect(engine.optionHeld)
        field.apply(engine.optionChanged(isDown: false))
        #expect(field.text == "ä")
    }

    @Test func interruptCommitsPendingAndCancelsDeadKey() {  // R13
        var engine = Engine()
        var field = FakeTextField()
        field.apply(engine.optionChanged(isDown: true))
        field.apply(engine.handle(KeyEvent(key: .character("e"), option: true)))
        field.apply(engine.interrupt())
        #expect(field.text == "é")
        #expect(field.marked == nil)
        field.apply(engine.optionChanged(isDown: false))
        field.apply(engine.optionChanged(isDown: true))
        field.apply(engine.handle(KeyEvent(key: .character(";"), option: true)))
        field.apply(engine.interrupt())
        #expect(field.text == "é")
        #expect(field.marked == nil)
        #expect(engine.markedText == nil)
    }

    @Test func controlOptionShortcutCommitsThenPassesThrough() {  // R12
        var engine = Engine()
        var field = FakeTextField()
        field.apply(engine.optionChanged(isDown: true))
        field.apply(engine.handle(KeyEvent(key: .character("a"), option: true)))
        let shortcut = KeyEvent(key: .character("t"), option: true, commandOrControl: true)
        let result = engine.handle(shortcut)
        field.apply(result, for: shortcut)
        #expect(result.passThrough)
        #expect(field.text == "ä")
        #expect(field.passedToApp == ["⌘t"])
    }

    @Test func optionArrowWithNothingPendingIsUntouched() {  // R11
        var engine = Engine()
        _ = engine.optionChanged(isDown: true)
        let result = engine.handle(KeyEvent(key: .function(.other), option: true))
        #expect(result == EngineResult(actions: [], passThrough: true))
    }

    @Test func unknownKeyCommitsThenPassesThrough() {  // R11
        var engine = Engine()
        var field = FakeTextField()
        field.apply(engine.optionChanged(isDown: true))
        field.apply(engine.handle(KeyEvent(key: .character("o"), option: true)))
        let jisEisu = KeyEvent(key: KeyCodeMap.key(for: 102), option: true)
        let result = engine.handle(jisEisu)
        field.apply(result, for: jisEisu)
        #expect(result.passThrough)
        #expect(field.text == "ö")
        #expect(field.marked == nil)
    }

    @Test func cancellingTheHeldCharacterReopensTheHold() {  // R10
        #expect(Typing.type("⌥(c ⌫ e s)").field.text == "ê")
    }

    @Test func waitingIAndYAreMarkedAndCancelledByDeleteOrEscape() {  // R2, R3, R10
        #expect(Typing.type("⌥(i").field.marked == "i")
        #expect(Typing.type("⌥(y").field.marked == "y")
        for script in ["⌥(i ⌫)", "⌥(i ⎋)", "⌥(y ⌫)", "⌥(y ⎋)"] {
            let field = Typing.type(script).field
            #expect(field.text.isEmpty, "\(script)")
            #expect(field.marked == nil, "\(script)")
            #expect(field.passedToApp.isEmpty, "\(script)")
        }
    }

    @Test func shortcutWithOptionUpClearsAStaleHold() {  // trust the event's own ⌥ flag + R12
        var engine = Engine()
        var field = FakeTextField()
        field.apply(engine.optionChanged(isDown: true))
        let a = KeyEvent(key: .character("a"), option: true)
        field.apply(engine.handle(a), for: a)
        let save = KeyEvent(key: .character("s"), commandOrControl: true)  // ⌥ already up; its flagsChanged was lost
        field.apply(engine.handle(save), for: save)
        #expect(engine.optionHeld == false)
        field.apply(engine.optionChanged(isDown: true))
        let e = KeyEvent(key: .character("e"), option: true)
        field.apply(engine.handle(e), for: e)
        field.apply(engine.optionChanged(isDown: false))
        #expect(field.text == "äé")
        #expect(field.passedToApp == ["⌘s"])
    }

    @Test func switchingOptionSidesKeepsOneHold() {  // R15
        // Left ⌥ down, right ⌥ down, left ⌥ up: the shell reports ⌥ down three times and never up.
        func type(_ first: Character, _ second: Character) -> String {
            var engine = Engine()
            var field = FakeTextField()
            field.apply(engine.optionChanged(isDown: true))
            let one = KeyEvent(key: .character(first), option: true)
            field.apply(engine.handle(one), for: one)
            field.apply(engine.optionChanged(isDown: true))  // right ⌥ joins
            field.apply(engine.optionChanged(isDown: true))  // left ⌥ lifts while right is held
            let two = KeyEvent(key: .character(second), option: true)
            field.apply(engine.handle(two), for: two)
            field.apply(engine.optionChanged(isDown: false))
            return field.text
        }
        #expect(type("c", "a") == "ça")  // still one hold, so R1 types the a plain
        #expect(type("a", "s") == "â")   // and a pair still forms across the switch
    }

    @Test func releasingOptionBetweenKeysStartsANewHold() {  // R15 boundary
        #expect(Typing.type("⌥(a) ⌥(s)").field.text == "äß")
    }

    @Test func optionReleaseTogetherWithShiftPressCommitsLowercase() {  // ⌥ is handled before Shift
        var engine = Engine()
        _ = engine.optionChanged(isDown: true)
        _ = engine.handle(KeyEvent(key: .character("e"), option: true))
        #expect(engine.flagsChanged(option: false, shift: true) == EngineResult(actions: [.insert("é")], passThrough: true))
    }

    @Test func shiftPressWhileOptionStaysDownCapitalizes() {  // RULES.md, Capitals
        var engine = Engine()
        _ = engine.optionChanged(isDown: true)
        _ = engine.handle(KeyEvent(key: .character("e"), option: true))
        #expect(engine.flagsChanged(option: true, shift: true) == EngineResult(actions: [.setMarked("É")], passThrough: true))
    }

    @Test func escapeCancelsLikeDelete() {  // R10
        for script in ["⌥(a ⎋)", "⌥(c ⎋)", "⌥(e e ⎋)", "⌥(; ⎋)", "⌥(;) ⎋"] {
            let field = Typing.type(script).field
            #expect(field.text.isEmpty, "\(script)")
            #expect(field.marked == nil, "\(script)")
            #expect(field.passedToApp.isEmpty, "\(script)")
        }
        #expect(Typing.type("⌥(a ⎋ o)").field.text == "ö")
        #expect(Typing.type("⌥(c ⎋ e s)").field.text == "ê")
    }

    @Test func escapeWithNothingMarkedGoesToTheApp() {  // R10
        #expect(Typing.type("⌥(⎋)").field.passedToApp == ["⌥⎋"])
    }

    @Test func semicolonAfterAPlainLetterIsStillADeadKey() {  // R8
        let field = Typing.type("⌥(t ;)").field
        #expect(field.text == "t")
        #expect(field.marked == "¨")
        #expect(Typing.type("⌥(t ; e)").field.text == "të")
    }

    @Test func semicolonAfterAWaitingTremaLetterMakesItsTrema() {  // R8, RULES.md, Core table
        for (letter, trema) in [("e", "ë"), ("i", "ï"), ("u", "ü"), ("y", "ÿ")] {
            let field = Typing.type("⌥(\(letter) ;").field
            #expect(field.marked == trema, "\(letter)")
            #expect(field.text.isEmpty, "\(letter)")
        }
        #expect(Typing.type("⌥(a ;)").field.text == "ä;")
        #expect(Typing.type("⌥(o ;)").field.text == "ö;")
    }

    @Test func semicolonInASpentHoldIsPlain() {  // R8, R7
        #expect(Typing.type("⌥(c ;)").field.text == "ç;")
        #expect(Typing.type("⌥(e e ;)").field.text == "è;")
        #expect(Typing.type("⌥(; x ;)").field.text == "x;")
        #expect(Typing.type("⌥(; ;)").field.text == ";")
    }

    @Test func semicolonAutorepeatIsIgnored() {  // R14
        #expect(Typing.type("⌥(; ;* e)").field.text == "ë")
        #expect(Typing.type("e e*").field.text == "ee")  // without ⌥, scheme keys repeat as usual
    }

    @Test func returnWhileTheDeadKeyWaits() {  // R7, R11
        let held = Typing.type("⌥(; ⏎)").field
        #expect(held.text.isEmpty)
        #expect(held.marked == nil)
        #expect(held.passedToApp == ["⌥⏎"])
        #expect(Typing.type("⌥(; ⏎ e)").field.text == "é")
        let released = Typing.type("⌥(;) ⏎").field
        #expect(released.text.isEmpty)
        #expect(released.marked == nil)
        #expect(released.passedToApp == ["⏎"])
    }

    @Test func commandShortcutWhileTheDeadKeyWaits() {  // R12
        for script in ["⌥(; ⌘s)", "⌥(;) ⌘s"] {
            let field = Typing.type(script).field
            #expect(field.text.isEmpty, "\(script)")
            #expect(field.marked == nil, "\(script)")
            #expect(field.passedToApp == ["⌘s"], "\(script)")
        }
    }

    @Test func keysForTheAppCommitFirst() {  // R11, R12: actions are applied before the app sees the key
        var enter = Engine()
        _ = enter.optionChanged(isDown: true)
        _ = enter.handle(KeyEvent(key: .character("a"), option: true))
        #expect(enter.handle(KeyEvent(key: .function(.other), option: true)) == EngineResult(actions: [.insert("ä")], passThrough: true))
        var shortcut = Engine()
        _ = shortcut.optionChanged(isDown: true)
        _ = shortcut.handle(KeyEvent(key: .character("e"), option: true))
        #expect(shortcut.handle(KeyEvent(key: .character("s"), option: true, commandOrControl: true)) == EngineResult(actions: [.insert("é")], passThrough: true))
    }
}
