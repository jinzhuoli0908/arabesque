/// What a key types without ⌥ on the ABC (QWERTY) layout (R16).
public enum PlainKeys {
    static let shifted: [Character: Character] = [
        "`": "~", "1": "!", "2": "@", "3": "#", "4": "$", "5": "%", "6": "^", "7": "&", "8": "*",
        "9": "(", "0": ")", "-": "_", "=": "+", "[": "{", "]": "}", "\\": "|", ";": ":", "'": "\"",
        ",": "<", ".": ">", "/": "?", "§": "±",
    ]

    /// `key` names a printable key by its unshifted ABC character ("a", "1", ";", " ", "§").
    public static func character(for key: Character, shift: Bool, capsLock: Bool) -> String {
        if key.isASCII && key.isLetter {
            return (shift || capsLock) ? key.uppercased() : String(key)
        }
        if shift, let shiftedKey = shifted[key] {
            return String(shiftedKey)
        }
        return String(key)
    }
}
