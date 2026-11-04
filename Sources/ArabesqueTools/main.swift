import ArabesqueSystem
import Carbon
import Foundation

// Developer tool for Arabesque.
// Usage: ArabesqueTools base-layout <out.keylayout> | icon <out.tiff> | register <path>
//        | enable <id> | disable <id> | select <id> | status <id> | find-layout <name>
//        | fallback-layout <name to exclude>
let arguments = CommandLine.arguments
guard arguments.count == 3 else {
    FileHandle.standardError.write(Data("usage: ArabesqueTools <command> <argument>\n".utf8))
    exit(2)
}
let command = arguments[1]
let argument = arguments[2]

do {
    switch command {
    case "base-layout":
        try BaseLayoutGenerator.write(to: URL(fileURLWithPath: argument))
    case "icon":
        try IconRenderer.write(to: URL(fileURLWithPath: argument))
    case "register":
        let status = TISRegisterInputSource(URL(fileURLWithPath: argument) as CFURL)
        print("TISRegisterInputSource -> \(status)")
        exit(status == 0 ? 0 : 1)
    case "find-layout":
        guard let id = InputSources.layoutID(named: argument) else {
            print("not found: \(argument)")
            exit(1)
        }
        print(id)
    case "fallback-layout":
        // The enabled layout to switch to when the input method goes away, never the layout named here.
        var excluded: Set<String> = []
        if let excludedID = InputSources.layoutID(named: argument) { excluded.insert(excludedID) }
        let enabled = InputSources.enabledKeyboardLayoutIDs()
        guard let id = InputSources.fallbackLayoutID(amongEnabled: enabled, excluding: excluded) else {
            print("none")
            exit(1)
        }
        print(id)
    case "enable", "disable", "select", "status":
        guard let source = InputSources.source(withID: argument) else {
            print("not found: \(argument)")
            exit(1)
        }
        switch command {
        case "enable": print("TISEnableInputSource -> \(TISEnableInputSource(source))")
        case "disable": print("TISDisableInputSource -> \(TISDisableInputSource(source))")
        case "select": print("TISSelectInputSource -> \(TISSelectInputSource(source))")
        default:
            print("\(argument): enabled=\(InputSources.flag(source, kTISPropertyInputSourceIsEnabled))"
                + " selected=\(InputSources.flag(source, kTISPropertyInputSourceIsSelected))")
        }
    default:
        FileHandle.standardError.write(Data("unknown command: \(command)\n".utf8))
        exit(2)
    }
} catch {
    FileHandle.standardError.write(Data("error: \(error)\n".utf8))
    exit(1)
}
