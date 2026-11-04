import Carbon
import Testing
@testable import ArabesqueCore

/// The symbol table (RULES.md, Symbol keys) must match what the system ABC layout really produces.
@Suite("Symbol keys match the system ABC layout")
struct SymbolTableTests {
    @Test func optionSymbolsMatchABC() throws {
        let abc = try #require(ABCLayout())
        let codes = Dictionary(uniqueKeysWithValues: KeyCodeMap.characters.map { ($0.value, $0.key) })
        for (key, symbol) in SymbolTable.option {
            #expect(abc.translate(codes[key]!, modifiers: optionKey) == String(symbol), "⌥\(String(key))")
        }
        for (key, symbol) in SymbolTable.optionShift {
            #expect(abc.translate(codes[key]!, modifiers: optionKey | shiftKey) == String(symbol), "⌥⇧\(String(key))")
        }
    }
}

/// Test-only reader for the system ABC layout.
struct ABCLayout {
    private let data: CFData

    init?() {
        let filter = [kTISPropertyInputSourceID as String: "com.apple.keylayout.ABC"] as CFDictionary
        guard let list = TISCreateInputSourceList(filter, true)?.takeRetainedValue() as? [TISInputSource],
              let source = list.first,
              let raw = TISGetInputSourceProperty(source, kTISPropertyUnicodeKeyLayoutData)
        else { return nil }
        data = Unmanaged<CFData>.fromOpaque(raw).takeUnretainedValue()
    }

    func translate(_ keyCode: UInt16, modifiers: Int) -> String {
        let layout = unsafeBitCast(CFDataGetBytePtr(data), to: UnsafePointer<UCKeyboardLayout>.self)
        var deadKeyState: UInt32 = 0
        var length = 0
        var chars = [UniChar](repeating: 0, count: 8)
        UCKeyTranslate(layout, keyCode, UInt16(kUCKeyActionDown), UInt32((modifiers >> 8) & 0xFF),
                       UInt32(LMGetKbdType()), OptionBits(kUCKeyTranslateNoDeadKeysMask),
                       &deadKeyState, chars.count, &length, &chars)
        return String(utf16CodeUnits: chars, count: length)
    }
}
