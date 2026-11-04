/// RULES.md, Symbol keys: ABC's ⌥ and ⌥⇧ symbols on digit and punctuation keys (rule R4).
/// Keys not listed here (letters, space, ' ` §) are typed plain.
public enum SymbolTable {
    public static let option: [Character: Character] = [
        "1": "¡", "2": "™", "3": "£", "4": "¢", "5": "∞", "6": "§", "7": "¶", "8": "•", "9": "ª", "0": "º",
        "-": "–", "=": "≠", "[": "“", "]": "‘", "\\": "«", ",": "≤", ".": "≥", "/": "÷",
    ]

    public static let optionShift: [Character: Character] = [
        "1": "⁄", "2": "€", "3": "‹", "4": "›", "5": "ﬁ", "6": "ﬂ", "7": "‡", "8": "°", "9": "·", "0": "‚",
        "-": "—", "=": "±", "[": "”", "]": "’", "\\": "»", ",": "¯", ".": "˘", "/": "¿",
    ]
}
