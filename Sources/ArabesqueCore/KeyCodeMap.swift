/// macOS virtual key codes → Key (ANSI positions plus the ISO § key).
/// Decide by the physical key, never by the characters macOS computed,
/// because those can carry ABC dead-key state.
public enum KeyCodeMap {
    static let characters: [UInt16: Character] = [
        0: "a", 1: "s", 2: "d", 3: "f", 4: "h", 5: "g", 6: "z", 7: "x", 8: "c", 9: "v",
        10: "§", 11: "b", 12: "q", 13: "w", 14: "e", 15: "r", 16: "y", 17: "t",
        18: "1", 19: "2", 20: "3", 21: "4", 22: "6", 23: "5", 24: "=", 25: "9", 26: "7",
        27: "-", 28: "8", 29: "0", 30: "]", 31: "o", 32: "u", 33: "[", 34: "i", 35: "p",
        37: "l", 38: "j", 39: "'", 40: "k", 41: ";", 42: "\\", 43: ",", 44: "/", 45: "n",
        46: "m", 47: ".", 49: " ", 50: "`",
    ]

    public static func key(for keyCode: UInt16) -> Key {
        if let character = characters[keyCode] {
            return .character(character)
        }
        switch keyCode {
        case 51: return .function(.delete)
        case 53: return .function(.escape)
        default: return .function(.other)
        }
    }
}
