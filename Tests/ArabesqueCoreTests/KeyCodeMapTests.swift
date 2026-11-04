import Carbon.HIToolbox
import Testing
@testable import ArabesqueCore

@Suite("KeyCodeMap")
struct KeyCodeMapTests {
    static let printable: [(Int, Character)] = [
        (kVK_ANSI_A, "a"), (kVK_ANSI_B, "b"), (kVK_ANSI_C, "c"), (kVK_ANSI_D, "d"), (kVK_ANSI_E, "e"),
        (kVK_ANSI_F, "f"), (kVK_ANSI_G, "g"), (kVK_ANSI_H, "h"), (kVK_ANSI_I, "i"), (kVK_ANSI_J, "j"),
        (kVK_ANSI_K, "k"), (kVK_ANSI_L, "l"), (kVK_ANSI_M, "m"), (kVK_ANSI_N, "n"), (kVK_ANSI_O, "o"),
        (kVK_ANSI_P, "p"), (kVK_ANSI_Q, "q"), (kVK_ANSI_R, "r"), (kVK_ANSI_S, "s"), (kVK_ANSI_T, "t"),
        (kVK_ANSI_U, "u"), (kVK_ANSI_V, "v"), (kVK_ANSI_W, "w"), (kVK_ANSI_X, "x"), (kVK_ANSI_Y, "y"),
        (kVK_ANSI_Z, "z"), (kVK_ANSI_0, "0"), (kVK_ANSI_1, "1"), (kVK_ANSI_2, "2"), (kVK_ANSI_3, "3"),
        (kVK_ANSI_4, "4"), (kVK_ANSI_5, "5"), (kVK_ANSI_6, "6"), (kVK_ANSI_7, "7"), (kVK_ANSI_8, "8"),
        (kVK_ANSI_9, "9"), (kVK_ANSI_Grave, "`"), (kVK_ANSI_Minus, "-"), (kVK_ANSI_Equal, "="),
        (kVK_ANSI_LeftBracket, "["), (kVK_ANSI_RightBracket, "]"), (kVK_ANSI_Backslash, "\\"),
        (kVK_ANSI_Semicolon, ";"), (kVK_ANSI_Quote, "'"), (kVK_ANSI_Comma, ","), (kVK_ANSI_Period, "."),
        (kVK_ANSI_Slash, "/"), (kVK_Space, " "), (kVK_ISO_Section, "§"),
    ]

    @Test func everyPrintableKeyMatchesCarbon() {
        for (code, character) in Self.printable {
            #expect(KeyCodeMap.key(for: UInt16(code)) == .character(character), "keyCode \(code)")
        }
        #expect(KeyCodeMap.characters.count == Self.printable.count)
    }

    @Test func deleteAndEscapeAreRecognised() {
        #expect(KeyCodeMap.key(for: UInt16(kVK_Delete)) == .function(.delete))
        #expect(KeyCodeMap.key(for: UInt16(kVK_Escape)) == .function(.escape))
    }

    @Test func everythingElseIsOther() {
        let codes = [kVK_Return, kVK_Tab, kVK_LeftArrow, kVK_UpArrow, kVK_ForwardDelete, kVK_Home,
                     kVK_F1, kVK_ANSI_Keypad1, kVK_ANSI_KeypadEnter, kVK_JIS_Eisu, kVK_JIS_Kana, kVK_JIS_Yen]
        for code in codes {
            #expect(KeyCodeMap.key(for: UInt16(code)) == .function(.other), "keyCode \(code)")
        }
    }
}
