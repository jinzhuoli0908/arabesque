import Testing
@testable import ArabesqueSystem

@Suite("Fallback layout for uninstall")
struct FallbackLayoutTests {
    let base = "org.unknown.keylayout.ArabesqueBase"

    @Test func prefersABC() {
        #expect(InputSources.fallbackLayoutID(amongEnabled: ["com.apple.keylayout.US", "com.apple.keylayout.ABC"], excluding: []) == "com.apple.keylayout.ABC")
    }
    @Test func usesUSWhenABCIsNotEnabled() {
        #expect(InputSources.fallbackLayoutID(amongEnabled: ["com.apple.keylayout.German", "com.apple.keylayout.US"], excluding: []) == "com.apple.keylayout.US")
    }
    @Test func otherwiseTakesTheFirstThatIsNotExcluded() {
        #expect(InputSources.fallbackLayoutID(amongEnabled: [base, "com.apple.keylayout.German"], excluding: [base]) == "com.apple.keylayout.German")
    }
    @Test func nilWhenNothingIsLeft() {
        #expect(InputSources.fallbackLayoutID(amongEnabled: [base], excluding: [base]) == nil)
    }

    // Exclusion applies to the preferred layouts too, not only to the "first one" fallback.
    @Test func skipsABCWhenItIsExcluded() {
        #expect(InputSources.fallbackLayoutID(amongEnabled: ["com.apple.keylayout.ABC", "com.apple.keylayout.US"], excluding: ["com.apple.keylayout.ABC"]) == "com.apple.keylayout.US")
    }
    @Test func skipsUSWhenItIsExcluded() {
        #expect(InputSources.fallbackLayoutID(amongEnabled: ["com.apple.keylayout.US", "com.apple.keylayout.German"], excluding: ["com.apple.keylayout.US"]) == "com.apple.keylayout.German")
    }
}
