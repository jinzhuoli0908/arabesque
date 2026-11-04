import Foundation
import Testing

@Suite("Base layout file")
struct BaseLayoutFileTests {
    static let layoutURL = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()   // ArabesqueCoreTests
        .deletingLastPathComponent()   // Tests
        .deletingLastPathComponent()   // repository root
        .appendingPathComponent("Resources/Arabesque Base.keylayout")

    /// The trimmed `<key …/>` lines between `<keyMap index="N">` and the next `</keyMap>`.
    static func keyLines(inMap index: Int, of text: String) -> [String] {
        let lines = text.components(separatedBy: "\n").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        guard let start = lines.firstIndex(of: #"<keyMap index="\#(index)">"#) else { return [] }
        return lines[(start + 1)...].prefix(while: { $0 != "</keyMap>" }).filter { $0.hasPrefix("<key ") }
    }

    /// macOS accepts negative keyboard ids only in group 126 (Unicode); under
    /// group 0 it logs "out of range" and replaces the id with 16383.
    @Test func headerUsesUnicodeGroupWithNegativeID() throws {
        let text = try String(contentsOf: Self.layoutURL, encoding: .utf8)
        let header = try #require(text.split(separator: "\n").first { $0.contains("<keyboard ") })
        #expect(header.contains(#"group="126""#))
        #expect(header.contains(#"id="-23817""#))
        #expect(header.contains(#"name="Arabesque Base""#))
    }

    /// The keylayout compiler turns outputs written as named entities (&apos; &quot; &amp; &lt; &gt;)
    /// into nothing, so those keys typed nothing. Numeric references (&#x0027;) work.
    @Test func usesOnlyNumericCharacterReferences() throws {
        let text = try String(contentsOf: Self.layoutURL, encoding: .utf8)
        let named = text.components(separatedBy: "&").dropFirst().filter { !$0.hasPrefix("#x") }
        #expect(named.isEmpty, "named entities: \(named.map { String($0.prefix(6)) })")
    }

    @Test func optionLayersCopyThePlainLayers() throws {  // no ⌥ dead keys can leak
        let text = try String(contentsOf: Self.layoutURL, encoding: .utf8)
        for (plain, option) in [(0, 3), (1, 4), (2, 5)] {
            #expect(!Self.keyLines(inMap: plain, of: text).isEmpty)
            #expect(Self.keyLines(inMap: option, of: text) == Self.keyLines(inMap: plain, of: text))
        }
    }

    @Test func hasNoDeadKeyStates() throws {
        let text = try String(contentsOf: Self.layoutURL, encoding: .utf8)
        #expect(!text.contains("<actions"))
        #expect(!text.contains("<terminators"))
        #expect(!text.contains("next="))
    }

    @Test func plainLayersAreABC() throws {  // R16
        let text = try String(contentsOf: Self.layoutURL, encoding: .utf8)
        let plain = Self.keyLines(inMap: 0, of: text)
        let shift = Self.keyLines(inMap: 1, of: text)
        for line in [#"<key code="0" output="a"/>"#, #"<key code="12" output="q"/>"#, #"<key code="39" output="&#x0027;"/>"#] {
            #expect(plain.contains(line))
        }
        for line in [#"<key code="0" output="A"/>"#, #"<key code="39" output="&#x0022;"/>"#, #"<key code="26" output="&#x0026;"/>"#,
                     #"<key code="43" output="&#x003C;"/>"#, #"<key code="47" output="&#x003E;"/>"#] {
            #expect(shift.contains(line))
        }
    }
}
