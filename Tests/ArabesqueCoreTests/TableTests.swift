import Testing
@testable import ArabesqueCore

@Suite("Data tables")
struct TableTests {
    @Test func coreTableMatchesTheRules() {
        // RULES.md, Core table, as code points, so a look-alike or decomposed character cannot pass.
        #expect(CoreTable.singles.mapValues { $0.unicodeScalars.map(\.value) } ==
                ["a": [0xE4], "o": [0xF6], "u": [0xFC], "s": [0xDF], "c": [0xE7], "e": [0xE9]])
        #expect(CoreTable.pairs.mapValues { $0.unicodeScalars.map(\.value) } ==
                ["ee": [0xE8], "es": [0xEA], "aa": [0xE0], "as": [0xE2], "ae": [0xE6],
                 "is": [0xEE], "os": [0xF4], "oe": [0x153], "uu": [0xF9], "us": [0xFB]])
        #expect(CoreTable.trema.mapValues { $0.unicodeScalars.map(\.value) } ==
                ["i": [0xEF], "e": [0xEB], "y": [0xFF], "u": [0xFC]])
    }

    @Test func postfixTremaMatchesTheRules() {  // RULES.md, Core table
        #expect(CoreTable.postfixTrema == ["e;": "ë", "i;": "ï", "u;": "ü", "y;": "ÿ"])
    }

    @Test func pairStartersAreTheFirstKeysOfThePairs() {  // R2, R8: a waiting letter starts a pair or a postfix tréma
        let firstKeys = Set(CoreTable.pairs.keys.map { $0.first! })
            .union(CoreTable.postfixTrema.keys.map { $0.first! })
        #expect(firstKeys == CoreTable.pairStarters)
    }

    @Test func bothUmlautAndTremaGiveTheSameU() {
        #expect(CoreTable.singles["u"] == CoreTable.trema["u"])
        #expect(CoreTable.trema["u"]!.unicodeScalars.map(\.value) == [0x00FC])
    }

    @Test func sharpSUppercasesToCapitalSharpS() {
        #expect(Casing.upper("ß") == "ẞ")
        #expect(Casing.upper("ß").unicodeScalars.map(\.value) == [0x1E9E])
        #expect(Casing.upper("œ") == "Œ")
        #expect(Casing.upper("ÿ") == "Ÿ")
        #expect(Casing.apply("é", upper: false) == "é")
    }

    @Test func wholeMarkedTextUppercases() {  // RULES.md, Capitals: capital after the fact
        #expect(Casing.upper(text: "é") == "É")
        #expect(Casing.upper(text: "ß") == "ẞ")
        #expect(Casing.upper(text: "œ") == "Œ")
    }

    @Test func plainKeysFollowABC() {
        #expect(PlainKeys.character(for: "a", shift: false, capsLock: false) == "a")
        #expect(PlainKeys.character(for: "a", shift: true, capsLock: false) == "A")
        #expect(PlainKeys.character(for: "a", shift: false, capsLock: true) == "A")
        #expect(PlainKeys.character(for: "1", shift: false, capsLock: true) == "1")
        #expect(PlainKeys.character(for: "1", shift: true, capsLock: false) == "!")
        #expect(PlainKeys.character(for: "'", shift: true, capsLock: false) == "\"")
        #expect(PlainKeys.character(for: " ", shift: true, capsLock: false) == " ")
    }

    @Test func symbolTableCoversTheSameKeysWithAndWithoutShift() {
        #expect(Set(SymbolTable.option.keys) == Set(SymbolTable.optionShift.keys))
        #expect(SymbolTable.option.count == 18)
        #expect(SymbolTable.option["-"] == "–")
        #expect(SymbolTable.optionShift["2"] == "€")
        #expect(SymbolTable.option["'"] == nil)
    }
}
