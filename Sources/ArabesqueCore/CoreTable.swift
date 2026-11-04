/// The Arabesque table (RULES.md, Core table). Normative: the convenience rules must never change these results.
public enum CoreTable {
    /// ⌥(x) gives one character.
    public static let singles: [Character: Character] = [
        "a": "ä", "o": "ö", "u": "ü", "s": "ß", "c": "ç", "e": "é",
    ]

    /// ⌥(x y) gives one character; the key order is strict.
    public static let pairs: [String: Character] = [
        "ee": "è", "es": "ê", "aa": "à", "as": "â", "ae": "æ",
        "is": "î", "os": "ô", "oe": "œ", "uu": "ù", "us": "û",
    ]

    /// ⌥(;) followed by one of these letters gives a tréma character.
    public static let trema: [Character: Character] = ["i": "ï", "e": "ë", "y": "ÿ", "u": "ü"]

    /// The dead key that starts a tréma, and what it shows while it waits.
    public static let deadKey: Character = ";"
    public static let deadKeyDisplay = "¨"

    /// ⌥(x ;) gives the same tréma characters as the dead key, with the keys in the other order.
    /// Derived from `trema` and `deadKey`, so the mapping has one source.
    public static let postfixTrema: [String: Character] = Dictionary(
        uniqueKeysWithValues: trema.map { (String($0.key) + String(deadKey), $0.value) })

    /// Letters that wait for a possible second key: the first key of every pair and of every postfix tréma.
    public static let pairStarters: Set<Character> = ["a", "e", "i", "o", "u", "y"]

    /// Every key of the scheme (RULES.md, Terms).
    public static let schemeKeys: Set<Character> = ["a", "o", "u", "s", "c", "e", "i", "y", ";"]
}
