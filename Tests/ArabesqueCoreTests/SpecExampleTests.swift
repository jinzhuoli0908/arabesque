import Testing
@testable import ArabesqueCore

struct ExampleCase: CustomTestStringConvertible, Sendable {
    let script: String
    let expected: String
    var capsLock = false
    var passedToApp: [String] = []

    var testDescription: String { (capsLock ? "⇪ " : "") + script }
}

/// Every row of the table in RULES.md, Examples.
@Suite("RULES.md examples")
struct SpecExampleTests {
    static let cases: [ExampleCase] = [
        // Core table
        ExampleCase(script: "⌥(a)", expected: "ä"),
        ExampleCase(script: "⌥(u s)", expected: "û"),
        ExampleCase(script: "⌥(u) ⌥(s)", expected: "üß"),
        ExampleCase(script: "⌥(e e)", expected: "è"),
        ExampleCase(script: "⌥(e) ⌥(e)", expected: "éé"),
        ExampleCase(script: "⌥(a e)", expected: "æ"),
        ExampleCase(script: "⌥(o e)", expected: "œ"),
        ExampleCase(script: "⌥(i s)", expected: "î"),
        ExampleCase(script: "⌥(;) i", expected: "ï"),
        ExampleCase(script: "⌥(;) y", expected: "ÿ"),
        ExampleCase(script: "⌥(; e)", expected: "ë"),
        ExampleCase(script: "⌥(e ;)", expected: "ë"),
        ExampleCase(script: "⌥(i ;)", expected: "ï"),
        ExampleCase(script: "⌥(u ;)", expected: "ü"),
        ExampleCase(script: "⌥(y ;)", expected: "ÿ"),
        // R1–R4, R7, R8
        ExampleCase(script: "⌥(c a)", expected: "ça"),
        ExampleCase(script: "⌥(e e s)", expected: "ès"),
        ExampleCase(script: "⌥(u c k)", expected: "ück"),
        ExampleCase(script: "⌥(s e)", expected: "ße"),
        ExampleCase(script: "⌥(e c)", expected: "éc"),
        ExampleCase(script: "⌥(e) ⌥(c)", expected: "éç"),
        ExampleCase(script: "⌥(a o)", expected: "äo"),
        ExampleCase(script: "⌥(i)", expected: "i"),
        ExampleCase(script: "⌥(i e e)", expected: "iè"),
        ExampleCase(script: "⌥(y)", expected: "y"),
        ExampleCase(script: "⌥(y e)", expected: "yé"),
        ExampleCase(script: "⌥(i ; e)", expected: "ïe"),
        ExampleCase(script: "⌥(o e i)", expected: "œi"),
        ExampleCase(script: "⌥(t e)", expected: "té"),
        ExampleCase(script: "⌥(a ;)", expected: "ä;"),
        ExampleCase(script: "⌥(;) x", expected: "x"),
        ExampleCase(script: "⌥(; a)", expected: "a"),
        ExampleCase(script: "⌥(; a s)", expected: "as"),
        ExampleCase(script: "⌥(;) ⌥(a)", expected: "a"),
        ExampleCase(script: "⌥(-)", expected: "–"),
        ExampleCase(script: "⌥(⇧-)", expected: "—"),
        ExampleCase(script: "⌥(\\)", expected: "«"),
        ExampleCase(script: "⌥(⇧\\)", expected: "»"),
        ExampleCase(script: "⌥(␣)", expected: " "),
        ExampleCase(script: "⌥(e ␣)", expected: "é "),
        ExampleCase(script: "⌥(e ,)", expected: "é,"),
        ExampleCase(script: "⌥(')", expected: "'"),
        // RULES.md, Capitals
        ExampleCase(script: "⌥(⇧a)", expected: "Ä"),
        ExampleCase(script: "⌥(⇧e s)", expected: "Ê"),
        ExampleCase(script: "⌥(e ⇧s)", expected: "Ê"),
        ExampleCase(script: "⌥(⇧e c)", expected: "Éc"),
        ExampleCase(script: "⌥(⇧c ⇧a)", expected: "ÇA"),
        ExampleCase(script: "⌥(⇧s)", expected: "ẞ"),
        ExampleCase(script: "⌥(⇧i ;)", expected: "Ï"),
        ExampleCase(script: "⌥(i ⇧;)", expected: "Ï"),
        ExampleCase(script: "⌥(; ⇧e)", expected: "Ë"),
        ExampleCase(script: "⌥(⇧; e)", expected: "ë"),
        ExampleCase(script: "⌥(⇧i)", expected: "I"),
        ExampleCase(script: "⌥(⇧t)", expected: "T"),
        ExampleCase(script: "⌥(e ⇧)", expected: "É"),
        ExampleCase(script: "⌥(e e ⇧)", expected: "È"),
        ExampleCase(script: "⌥(c ⇧)", expected: "Ç"),
        ExampleCase(script: "⌥(s ⇧)", expected: "ẞ"),
        ExampleCase(script: "⌥(o e ⇧)", expected: "Œ"),
        ExampleCase(script: "⌥(a ⇧)", expected: "Ä"),
        ExampleCase(script: "⌥(i s ⇧)", expected: "Î"),
        ExampleCase(script: "⌥(; e ⇧)", expected: "Ë"),
        ExampleCase(script: "⌥(i ; ⇧)", expected: "Ï"),
        ExampleCase(script: "⌥(i ⇧ s)", expected: "Î"),
        ExampleCase(script: "⌥(a ⇧o)", expected: "ÄO"),
        ExampleCase(script: "⌥(; ⇧ e)", expected: "Ë"),
        ExampleCase(script: "⌥(e) ⇧", expected: "é"),
        ExampleCase(script: "⌥(⇧ e)", expected: "É"),
        ExampleCase(script: "⌥(⇧ e e)", expected: "È"),
        ExampleCase(script: "⌥(⇧ a s)", expected: "Â"),
        ExampleCase(script: "⌥(⇧ c a)", expected: "Ça"),
        ExampleCase(script: "⌥(⇧ t)", expected: "T"),
        ExampleCase(script: "⌥(⇧ -)", expected: "—"),
        ExampleCase(script: "⌥(⇧ ; e)", expected: "ë"),
        ExampleCase(script: "⌥(⇧ ⏎ e)", expected: "é", passedToApp: ["⌥⏎"]),
        ExampleCase(script: "⌥(⇧) e", expected: "e"),
        ExampleCase(script: "⌥(s)", expected: "ẞ", capsLock: true),
        ExampleCase(script: "⌥(i s)", expected: "Î", capsLock: true),
        ExampleCase(script: "⌥(i)", expected: "I", capsLock: true),
        ExampleCase(script: "⌥(;) e", expected: "Ë", capsLock: true),
        ExampleCase(script: "⌥(-)", expected: "–", capsLock: true),
        // R10 ⌫ / Esc
        ExampleCase(script: "⌥(a ⌫)", expected: ""),
        ExampleCase(script: "⌥(c ⌫)", expected: ""),
        ExampleCase(script: "⌥(e e ⌫)", expected: ""),
        ExampleCase(script: "⌥(; ⌫)", expected: ""),
        ExampleCase(script: "⌥(a ⌫ o)", expected: "ö"),
        ExampleCase(script: "⌥(⌫)", expected: "", passedToApp: ["⌥⌫"]),
        // R14 autorepeat
        ExampleCase(script: "⌥(e e*)", expected: "é"),
        ExampleCase(script: "⌥(e e* s)", expected: "ê"),
        ExampleCase(script: "⌥(o o*)", expected: "ö"),
        ExampleCase(script: "⌥(y y*)", expected: "y"),
        // R11–R13
        ExampleCase(script: "⌥(a ⏎)", expected: "ä", passedToApp: ["⌥⏎"]),
        ExampleCase(script: "⌥(e ⌘s)", expected: "é", passedToApp: ["⌘s"]),
        ExampleCase(script: "⌥(a CLICK)", expected: "ä"),
        ExampleCase(script: "⌥(;) CLICK x", expected: "x"),
    ]

    @Test(arguments: cases)
    func example(_ example: ExampleCase) {
        let field = Typing.type(example.script, capsLock: example.capsLock).field
        #expect(field.text == example.expected)
        #expect(field.marked == nil)
        #expect(field.passedToApp == example.passedToApp)
    }

    @Test func tableRowCountMatchesSpec() {
        #expect(Self.cases.count == 95)
    }
}
