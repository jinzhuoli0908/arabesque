/// A physical key, independent of AppKit.
public enum Key: Hashable, Sendable {
    /// A printable key, named by what it types on ABC without modifiers ("a", "1", ";", " ", "§").
    case character(Character)
    case function(FunctionKey)
}

public enum FunctionKey: Hashable, Sendable {
    /// ⌫
    case delete
    case escape
    /// Return, Tab, arrows, ⌦, Home/End, Page Up/Down, F-keys, keypad and any unknown key.
    case other
}

/// One key press as the engine sees it.
public struct KeyEvent: Equatable, Sendable {
    public var key: Key
    public var shift: Bool
    public var capsLock: Bool
    public var option: Bool
    public var commandOrControl: Bool
    public var isRepeat: Bool

    public init(key: Key, shift: Bool = false, capsLock: Bool = false, option: Bool = false,
                commandOrControl: Bool = false, isRepeat: Bool = false) {
        self.key = key
        self.shift = shift
        self.capsLock = capsLock
        self.option = option
        self.commandOrControl = commandOrControl
        self.isRepeat = isRepeat
    }
}
