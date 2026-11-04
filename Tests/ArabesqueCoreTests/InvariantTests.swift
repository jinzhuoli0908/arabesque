import Testing
@testable import ArabesqueCore

/// RULES.md, Rules, principle 1: whatever happened before, a hold that types exactly
/// one core-table entry produces exactly that entry's character.
@Suite("Principle 1: core results are never changed")
struct InvariantTests {
    /// Deterministic generator so failures can be replayed.
    struct SplitMix64: RandomNumberGenerator {
        var state: UInt64
        mutating func next() -> UInt64 {
            state &+= 0x9E37_79B9_7F4A_7C15
            var z = state
            z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
            z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
            return z ^ (z >> 31)
        }
    }

    struct Entry {
        let keys: [Character]
        let expected: String
        let isTrema: Bool
    }

    /// Every printable key plus ⌫, Esc and another function key, in a fixed order (sorted by key code).
    static let pool: [Key] = KeyCodeMap.characters.keys.sorted().map { Key.character(KeyCodeMap.characters[$0]!) }
        + [.function(.delete), .function(.escape), .function(.other)]

    /// All 24 core entries, sorted so a given seed always replays the same sequence.
    static let entries: [Entry] =
        CoreTable.singles.sorted { $0.key < $1.key }
            .map { Entry(keys: [$0.key], expected: String($0.value), isTrema: false) }
        + CoreTable.pairs.sorted { $0.key < $1.key }
            .map { Entry(keys: Array($0.key), expected: String($0.value), isTrema: false) }
        + CoreTable.postfixTrema.sorted { $0.key < $1.key }
            .map { Entry(keys: Array($0.key), expected: String($0.value), isTrema: false) }
        + CoreTable.trema.sorted { $0.key < $1.key }
            .map { Entry(keys: [$0.key], expected: String($0.value), isTrema: true) }

    @Test func coreEntriesSurviveRandomHistory() {
        var rng = SplitMix64(state: 20_261_010)
        for _ in 0..<3000 {
            var engine = Engine()
            var field = FakeTextField()
            for _ in 0..<Int.random(in: 0...6, using: &rng) {
                let option = Bool.random(using: &rng)
                if option { field.apply(engine.optionChanged(isDown: true)) }
                for _ in 0..<Int.random(in: 1...4, using: &rng) {
                    if Int.random(in: 0..<4, using: &rng) == 0 {
                        field.apply(engine.shiftChanged(isDown: Bool.random(using: &rng)))
                    }
                    let event = KeyEvent(key: Self.pool.randomElement(using: &rng)!,
                                         shift: Bool.random(using: &rng), option: option,
                                         isRepeat: Int.random(in: 0..<10, using: &rng) == 0)
                    field.apply(engine.handle(event), for: event)
                }
                if Int.random(in: 0..<4, using: &rng) == 0 {  // Shift just before ⌥ is released (RULES.md, Capitals)
                    field.apply(engine.shiftChanged(isDown: Bool.random(using: &rng)))
                }
                if option { field.apply(engine.optionChanged(isDown: false)) }
                if Int.random(in: 0..<8, using: &rng) == 0 { field.apply(engine.interrupt()) }
            }
            // A dead key left waiting legitimately combines with the next letter (R6), so cancel it first.
            if engine.markedText == CoreTable.deadKeyDisplay {
                let escape = KeyEvent(key: .function(.escape))
                field.apply(engine.handle(escape), for: escape)
            }

            let entry = Self.entries.randomElement(using: &rng)!
            let before = field.insertions.count
            field.apply(engine.optionChanged(isDown: true))
            if entry.isTrema {
                field.apply(engine.handle(KeyEvent(key: .character(";"), option: true)))
                field.apply(engine.optionChanged(isDown: false))
                let letter = KeyEvent(key: .character(entry.keys[0]))
                field.apply(engine.handle(letter), for: letter)
            } else {
                for key in entry.keys {
                    field.apply(engine.handle(KeyEvent(key: .character(key), option: true)))
                }
                field.apply(engine.optionChanged(isDown: false))
            }
            #expect(field.insertions[before...].joined() == entry.expected)
        }
    }
}
