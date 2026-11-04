import Testing
@testable import ArabesqueCore

/// RULES.md, Capitals: Shift tapped during a ⌥ hold, after the letter (it capitalizes at once)
/// or before it (it arms the next key), and the cases where a Shift press is not a tap.
@Suite("Shift taps")
struct ShiftTests {
    @Test func shiftPressedAfterTheLetterCapitalizesTheMarkedCharacter() {  // RULES.md, Capitals
        var engine = Engine()
        var field = FakeTextField()
        field.apply(engine.optionChanged(isDown: true))
        let e = KeyEvent(key: .character("e"), option: true)
        field.apply(engine.handle(e), for: e)
        #expect(field.marked == "é")
        field.apply(engine.shiftChanged(isDown: true))
        #expect(field.marked == "É")  // visible at once
        field.apply(engine.shiftChanged(isDown: false))
        #expect(field.marked == "É")  // releasing Shift does not undo it
        field.apply(engine.optionChanged(isDown: false))
        #expect(field.text == "É")
    }

    @Test func secondKeyShiftAloneStillCapitalizesAPair() {  // RULES.md, Capitals: the keyDown's own flag, when no Shift press was seen
        var engine = Engine()
        var field = FakeTextField()
        field.apply(engine.optionChanged(isDown: true))
        let e = KeyEvent(key: .character("e"), option: true)
        field.apply(engine.handle(e), for: e)
        let s = KeyEvent(key: .character("s"), shift: true, option: true)  // no shiftChanged before it
        field.apply(engine.handle(s), for: s)
        #expect(field.marked == "Ê")
        field.apply(engine.optionChanged(isDown: false))
        #expect(field.text == "Ê")
    }

    @Test func shiftAfterEveryCoreEntryGivesItsCapital() {  // RULES.md, Capitals, whole table
        func check(_ keys: [Character], _ result: Character, _ label: String) {
            let hold = "⌥(" + keys.map { String($0) }.joined(separator: " ")
            let capital = Casing.upper(result)
            #expect(Typing.type(hold + " ⇧").field.marked == capital, "\(label): capital shown at once")
            #expect(Typing.type(hold + " ⇧)").field.text == capital, "\(label): capital committed")
        }
        for (key, single) in CoreTable.singles { check([key], single, "single \(key)") }
        for (keys, pair) in CoreTable.pairs { check(Array(keys), pair, "pair \(keys)") }
        for (keys, trema) in CoreTable.postfixTrema { check(Array(keys), trema, "postfix tréma \(keys)") }
        for (key, trema) in CoreTable.trema { check([";", key], trema, "tréma \(key)") }
    }

    @Test func shiftAloneShowsNothingWithoutMarkedText() {  // RULES.md, Capitals
        var engine = Engine()
        #expect(engine.shiftChanged(isDown: true).actions.isEmpty)
        #expect(engine.shiftChanged(isDown: false).actions.isEmpty)
    }

    @Test func aKeyDownResyncsALostShiftRelease() {  // RULES.md, Capitals, trusting the event's own Shift flag
        var engine = Engine()
        var field = FakeTextField()
        _ = engine.shiftChanged(isDown: true)  // Shift goes down…
        let x = KeyEvent(key: .character("x"))  // …but this key says it is up: the release was lost
        field.apply(engine.handle(x), for: x)
        field.apply(engine.optionChanged(isDown: true))
        let e = KeyEvent(key: .character("e"), option: true)
        field.apply(engine.handle(e), for: e)
        field.apply(engine.shiftChanged(isDown: true))  // a real press must still count
        field.apply(engine.optionChanged(isDown: false))
        #expect(field.text == "xÉ")
    }

    @Test func shiftPressOnAnAlreadyCapitalMarkChangesNothing() {  // RULES.md, Capitals, Caps Lock
        for key: Character in ["e", "c"] {  // a pending and a held character
            var engine = Engine()
            var field = FakeTextField()
            field.apply(engine.optionChanged(isDown: true))
            let event = KeyEvent(key: .character(key), capsLock: true, option: true)
            field.apply(engine.handle(event), for: event)
            #expect(engine.shiftChanged(isDown: true).actions.isEmpty, "key \(key)")
        }
    }

    @Test func everyKeyDownPathResyncsShift() {  // RULES.md, Capitals, trusting the event's own Shift flag
        let events = [
            KeyEvent(key: .character("s"), commandOrControl: true),         // R12
            KeyEvent(key: .character("e"), option: true, isRepeat: true),   // R14
            KeyEvent(key: .function(.other), option: true),                 // R11
            KeyEvent(key: .character("x")),                                 // plain typing
        ]
        for event in events {
            var engine = Engine()
            _ = engine.shiftChanged(isDown: true)  // pretend the release was lost
            _ = engine.handle(event)               // this key says Shift is up
            #expect(engine.shiftHeld == false, "\(event)")
        }
    }

    @Test func shiftTapBeforeTheLetterArmsTheNextKey() {  // RULES.md, Capitals
        var engine = Engine()
        var field = FakeTextField()
        field.apply(engine.optionChanged(isDown: true))
        field.apply(engine.shiftChanged(isDown: true))
        field.apply(engine.shiftChanged(isDown: false))
        #expect(engine.shiftArmed)
        #expect(field.marked == nil)  // nothing to show yet (R5)
        let e = KeyEvent(key: .character("e"), option: true)
        field.apply(engine.handle(e), for: e)
        #expect(field.marked == "É")
        #expect(!engine.shiftArmed)  // used up by the first key
        field.apply(engine.optionChanged(isDown: false))
        #expect(field.text == "É")
    }

    @Test func shiftUsedForAKeyIsAChordNotATap() {  // RULES.md, Capitals: an early ⌥ must not turn Déjà into DÉjà
        var engine = Engine()
        var field = FakeTextField()
        field.apply(engine.optionChanged(isDown: true))  // ⌥ pressed too early
        field.apply(engine.shiftChanged(isDown: true))
        let d = KeyEvent(key: .character("d"), shift: true, option: true)
        field.apply(engine.handle(d), for: d)
        field.apply(engine.shiftChanged(isDown: false))
        #expect(!engine.shiftArmed)
        let e = KeyEvent(key: .character("e"), option: true)
        field.apply(engine.handle(e), for: e)
        field.apply(engine.optionChanged(isDown: false))
        #expect(field.text == "Dé")
    }

    @Test func shiftPressedBeforeOptionAndReleasedDuringTheHoldIsATap() {  // RULES.md, Capitals
        var engine = Engine()
        var field = FakeTextField()
        field.apply(engine.shiftChanged(isDown: true))
        field.apply(engine.optionChanged(isDown: true))
        field.apply(engine.shiftChanged(isDown: false))
        let e = KeyEvent(key: .character("e"), option: true)
        field.apply(engine.handle(e), for: e)
        field.apply(engine.optionChanged(isDown: false))
        #expect(field.text == "É")
    }

    @Test func armIsOnlyForThisHold() {  // RULES.md, Capitals
        var engine = Engine()
        var field = FakeTextField()
        field.apply(engine.optionChanged(isDown: true))
        field.apply(engine.shiftChanged(isDown: true))
        field.apply(engine.shiftChanged(isDown: false))
        field.apply(engine.optionChanged(isDown: false))
        #expect(!engine.shiftArmed)
        field.apply(engine.optionChanged(isDown: true))
        let e = KeyEvent(key: .character("e"), option: true)
        field.apply(engine.handle(e), for: e)
        field.apply(engine.optionChanged(isDown: false))
        #expect(field.text == "é")
    }

    @Test func shortcutAndInterruptClearTheArm() {  // RULES.md, Capitals, R12, R13
        for clear in ["shortcut", "interrupt"] {
            var engine = Engine()
            var field = FakeTextField()
            field.apply(engine.optionChanged(isDown: true))
            field.apply(engine.shiftChanged(isDown: true))
            field.apply(engine.shiftChanged(isDown: false))
            if clear == "shortcut" {
                let save = KeyEvent(key: .character("s"), option: true, commandOrControl: true)
                field.apply(engine.handle(save), for: save)
            } else {
                field.apply(engine.interrupt())
            }
            #expect(!engine.shiftArmed, "\(clear)")
        }
    }

    @Test func tapBeforeEveryCoreEntryGivesItsCapital() {  // RULES.md, Capitals, whole table
        for (key, single) in CoreTable.singles {
            #expect(Typing.type("⌥(⇧ \(key))").field.text == Casing.upper(single), "single \(key)")
        }
        for (keys, pair) in CoreTable.pairs {
            let script = "⌥(⇧ " + keys.map { String($0) }.joined(separator: " ") + ")"
            #expect(Typing.type(script).field.text == Casing.upper(pair), "pair \(keys)")
        }
        for (keys, trema) in CoreTable.postfixTrema {
            let script = "⌥(⇧ " + keys.map { String($0) }.joined(separator: " ") + ")"
            #expect(Typing.type(script).field.text == Casing.upper(trema), "postfix tréma \(keys)")
        }
        for (key, trema) in CoreTable.trema {
            #expect(Typing.type("⌥(; ⇧ \(key))").field.text == Casing.upper(trema), "tréma \(key)")
        }
    }

    @Test func shiftTapOutsideAHoldDoesNotArm() {  // RULES.md, Capitals: a tap counts only while ⌥ is held
        var engine = Engine()
        var field = FakeTextField()
        field.apply(engine.shiftChanged(isDown: true))
        field.apply(engine.shiftChanged(isDown: false))
        #expect(!engine.shiftArmed)
        let a = KeyEvent(key: .character("a"))
        field.apply(engine.handle(a), for: a)
        #expect(field.text == "a")  // plain typing is untouched
    }

    @Test func anAutorepeatDoesNotUseUpTheArm() {  // RULES.md, Capitals: only the first non-repeat key does
        var engine = Engine()
        var field = FakeTextField()
        field.apply(engine.optionChanged(isDown: true))
        let dash = KeyEvent(key: .character("-"), option: true)
        field.apply(engine.handle(dash), for: dash)  // ⌥- = –, and the key stays down
        field.apply(engine.shiftChanged(isDown: true))
        field.apply(engine.shiftChanged(isDown: false))
        let repeated = KeyEvent(key: .character("-"), option: true, isRepeat: true)
        field.apply(engine.handle(repeated), for: repeated)
        #expect(engine.shiftArmed)
        let e = KeyEvent(key: .character("e"), option: true)
        field.apply(engine.handle(e), for: e)
        field.apply(engine.optionChanged(isDown: false))
        #expect(field.text == "––É")
    }

    @Test func releasingOptionForgetsAShiftThatIsStillDown() {  // RULES.md, Capitals: a tap lives inside one hold
        var engine = Engine()
        _ = engine.optionChanged(isDown: true)
        _ = engine.shiftChanged(isDown: true)    // nothing marked: a possible tap
        _ = engine.optionChanged(isDown: false)  // the hold ends while Shift stays down
        _ = engine.optionChanged(isDown: true)   // a new hold
        _ = engine.shiftChanged(isDown: false)   // Shift comes up in it
        #expect(!engine.shiftArmed)
    }

    @Test func aClickForgetsAShiftThatIsStillDown() {  // RULES.md, Capitals, R13
        var engine = Engine()
        _ = engine.optionChanged(isDown: true)
        _ = engine.shiftChanged(isDown: true)
        _ = engine.interrupt()
        _ = engine.shiftChanged(isDown: false)
        #expect(!engine.shiftArmed)
    }

    @Test func aRepeatedShiftDownReportDoesNotStartANewTap() {  // RULES.md, Capitals: the shell reports Shift on every flagsChanged
        var engine = Engine()
        var field = FakeTextField()
        field.apply(engine.shiftChanged(isDown: true))
        let d = KeyEvent(key: .character("d"), shift: true)  // a capital typed before ⌥
        field.apply(engine.handle(d), for: d)
        field.apply(engine.optionChanged(isDown: true))  // ⌥ joins while Shift is still down…
        field.apply(engine.shiftChanged(isDown: true))   // …and the same flagsChanged reports Shift again
        field.apply(engine.shiftChanged(isDown: false))
        #expect(!engine.shiftArmed)
        let e = KeyEvent(key: .character("e"), option: true)
        field.apply(engine.handle(e), for: e)
        field.apply(engine.optionChanged(isDown: false))
        #expect(field.text == "Dé")
    }

    @Test func theArmedKeyLeavesShiftHeldAtItsRealFlag() {  // RULES.md, Capitals: the arm shifts the key, not our record of Shift
        var engine = Engine()
        var field = FakeTextField()
        field.apply(engine.optionChanged(isDown: true))
        field.apply(engine.shiftChanged(isDown: true))
        field.apply(engine.shiftChanged(isDown: false))
        let semicolon = KeyEvent(key: .character(";"), option: true)  // uses up the arm; ; ignores Shift
        field.apply(engine.handle(semicolon), for: semicolon)
        #expect(!engine.shiftHeld)
        field.apply(engine.shiftChanged(isDown: true))  // a second tap must still be a tap
        field.apply(engine.shiftChanged(isDown: false))
        let e = KeyEvent(key: .character("e"), option: true)
        field.apply(engine.handle(e), for: e)
        field.apply(engine.optionChanged(isDown: false))
        #expect(field.text == "Ë")
    }

    @Test func shiftBeforeTheLetterIsSetNotToggled() {  // RULES.md, Capitals: a second tap, or a chord on top of the arm, is still one Shift
        #expect(Typing.type("⌥(⇧ ⇧ e)").field.text == "É")  // tap, tap
        #expect(Typing.type("⌥(⇧ ⇧e)").field.text == "É")   // tap, chord
    }
}
