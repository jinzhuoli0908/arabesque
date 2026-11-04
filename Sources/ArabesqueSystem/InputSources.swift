import Carbon
import Foundation

/// Thin helpers around Text Input Sources (TIS), shared by the input method and the tools.
public enum InputSources {
    /// Name of the private base layout and the layout used when it is missing.
    public static let baseLayoutName = "Arabesque Base"
    public static let fallbackLayoutID = "com.apple.keylayout.ABC"

    /// TIS ID of the installed private base layout, or ABC when it is not installed.
    public static func baseLayoutID() -> String {
        layoutID(named: baseLayoutName) ?? fallbackLayoutID
    }

    /// TIS ID of the installed keyboard layout with this localized name.
    public static func layoutID(named name: String) -> String? {
        let filter = [kTISPropertyInputSourceType as String: kTISTypeKeyboardLayout as String] as CFDictionary
        let list = TISCreateInputSourceList(filter, true)?.takeRetainedValue() as? [TISInputSource] ?? []
        for source in list where string(source, kTISPropertyLocalizedName) == name {
            return string(source, kTISPropertyInputSourceID)
        }
        return nil
    }

    /// IDs of the enabled keyboard layouts that can be selected, in the order TIS lists them.
    public static func enabledKeyboardLayoutIDs() -> [String] {
        let filter = [kTISPropertyInputSourceType as String: kTISTypeKeyboardLayout as String] as CFDictionary
        // `false`: only the enabled sources, not every installed one.
        let list = TISCreateInputSourceList(filter, false)?.takeRetainedValue() as? [TISInputSource] ?? []
        return list.compactMap { source in
            flag(source, kTISPropertyInputSourceIsSelectCapable) ? string(source, kTISPropertyInputSourceID) : nil
        }
    }

    /// The layout to select when Arabesque is removed: ABC if it is among `ids`, else US, else the first
    /// of `ids`. Layouts in `excluded` are never chosen; nil when none is left. Pure: no TIS access.
    public static func fallbackLayoutID(amongEnabled ids: [String], excluding excluded: Set<String>) -> String? {
        let candidates = ids.filter { !excluded.contains($0) }
        // ABC is the `fallbackLayoutID` constant above (this function shares its name).
        let preferred: [String] = [fallbackLayoutID, "com.apple.keylayout.US"]
        return preferred.first(where: candidates.contains) ?? candidates.first
    }

    public static func source(withID id: String) -> TISInputSource? {
        let filter = [kTISPropertyInputSourceID as String: id] as CFDictionary
        let list = TISCreateInputSourceList(filter, true)?.takeRetainedValue() as? [TISInputSource]
        return list?.first
    }

    public static func flag(_ source: TISInputSource, _ key: CFString) -> Bool {
        guard let raw = TISGetInputSourceProperty(source, key) else { return false }
        return CFBooleanGetValue(Unmanaged<CFBoolean>.fromOpaque(raw).takeUnretainedValue())
    }

    public static func string(_ source: TISInputSource, _ key: CFString) -> String? {
        guard let raw = TISGetInputSourceProperty(source, key) else { return nil }
        return Unmanaged<CFString>.fromOpaque(raw).takeUnretainedValue() as String
    }
}
