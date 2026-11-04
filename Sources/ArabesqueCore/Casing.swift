/// Upper-casing of output characters (RULES.md, Capitals).
public enum Casing {
    /// ß becomes ẞ (U+1E9E); Swift's uppercased() would give "SS".
    public static func upper(_ character: Character) -> String {
        character == "ß" ? "ẞ" : String(character).uppercased()
    }

    /// Upper-cases marked text, keeping ß → ẞ. Labelled so string literals never become ambiguous.
    public static func upper(text: String) -> String {
        text.map { upper($0) }.joined()
    }

    public static func apply(_ character: Character, upper isUpper: Bool) -> String {
        isUpper ? upper(character) : String(character)
    }
}
