import Foundation
import Testing
@testable import ArabesqueCore

/// docs/RULES.md must match the code. Its core table (RULES.md, Core table) matches `CoreTable`,
/// and its examples (RULES.md, Examples) match `SpecExampleTests` row for row.
@Suite("RULES.md tables match the code")
struct RulesDocumentTests {
    static let documentURL = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()   // ArabesqueCoreTests
        .deletingLastPathComponent()   // Tests
        .deletingLastPathComponent()   // repository root
        .appendingPathComponent("docs/RULES.md")

    /// How many cells every data row of a section has.
    static let columns = ["core": 2, "examples": 4]

    struct FormatError: Error, CustomStringConvertible {
        let description: String
    }

    /// The cells of each data row (a line starting with "| `") between `<!-- section:begin -->` and
    /// `<!-- section:end -->`, without surrounding spaces and backticks. A missing section or a row with
    /// the wrong number of cells throws, so the test fails instead of crashing on a missing cell.
    static func rows(_ section: String) throws -> [[String]] {
        let text = try String(contentsOf: documentURL, encoding: .utf8)
        let lines = text.components(separatedBy: "\n").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        guard let count = columns[section],
              let begin = lines.firstIndex(of: "<!-- \(section):begin -->"),
              let end = lines.firstIndex(of: "<!-- \(section):end -->"), begin < end
        else { throw FormatError(description: "RULES.md has no \(section) section") }
        let trim = CharacterSet.whitespaces.union(CharacterSet(charactersIn: "`"))
        let rows = lines[(begin + 1)..<end].filter { $0.hasPrefix("| `") }.map { line in
            line.split(separator: "|", omittingEmptySubsequences: false).dropFirst().dropLast()
                .map { $0.trimmingCharacters(in: trim) }
        }
        if let bad = rows.first(where: { $0.count != count }) {
            throw FormatError(description: "a \(section) row has \(bad.count) cells, not \(count): \(bad)")
        }
        return rows
    }

    @Test func coreTableMatchesTheEngine() throws {
        var expected: [String: String] = [:]
        for (key, value) in CoreTable.singles { expected["⌥(\(key))"] = String(value) }
        for (keys, value) in CoreTable.pairs { expected["⌥(\(keys.first!) \(keys.last!))"] = String(value) }
        for (key, value) in CoreTable.trema { expected["⌥(;) \(key)"] = String(value) }
        for (keys, value) in CoreTable.postfixTrema { expected["⌥(\(keys.first!) \(keys.last!))"] = String(value) }
        let rows = try Self.rows("core")
        #expect(rows.count == 24)
        #expect(Set(rows.map { $0[0] }).count == rows.count)  // no key twice
        #expect(Dictionary(rows.map { ($0[0], $0[1]) }, uniquingKeysWith: { first, _ in first }) == expected)
    }

    @Test func examplesMatchTheTests() throws {
        let rows = try Self.rows("examples")
        #expect(rows.count == SpecExampleTests.cases.count)
        for (row, example) in zip(rows, SpecExampleTests.cases) {
            #expect(row[0] == example.testDescription)
            #expect(row[1] == (example.expected.isEmpty ? "(nothing)" : example.expected.replacingOccurrences(of: " ", with: "␣")))
            #expect(row[2] == example.passedToApp.joined(separator: ", "))
        }
    }
}
