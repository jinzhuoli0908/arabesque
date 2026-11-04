import Cocoa
import InputMethodKit

guard let connectionName = Bundle.main.infoDictionary?["InputMethodConnectionName"] as? String else {
    NSLog("Arabesque: Info.plist is missing InputMethodConnectionName")
    exit(1)
}

// The server must stay alive for the whole process.
let server = IMKServer(name: connectionName, bundleIdentifier: Bundle.main.bundleIdentifier)
NSApplication.shared.run()
