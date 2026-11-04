import Foundation
import Testing

@Suite("Info.plist")
struct InfoPlistTests {
    static let plistURL = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()   // ArabesqueCoreTests
        .deletingLastPathComponent()   // Tests
        .deletingLastPathComponent()   // repository root
        .appendingPathComponent("Resources/Info.plist")

    static func plist() throws -> [String: Any] {
        let data = try Data(contentsOf: plistURL)
        let object = try PropertyListSerialization.propertyList(from: data, format: nil)
        return try #require(object as? [String: Any])
    }

    /// The bundle ID and the input source ID are the same string; the connection name derives from it.
    @Test func identifiersMatchTheReleaseID() throws {
        let plist = try Self.plist()
        #expect(plist["CFBundleIdentifier"] as? String == "li.jinzhuo.inputmethod.Arabesque")
        #expect(plist["TISInputSourceID"] as? String == "li.jinzhuo.inputmethod.Arabesque")
        #expect(plist["InputMethodConnectionName"] as? String == "li.jinzhuo.inputmethod.Arabesque_Connection")
    }

    @Test func versionIsTheReleaseVersion() throws {
        #expect(try Self.plist()["CFBundleShortVersionString"] as? String == "1.0.0")
    }
}
