// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Arabesque",
    platforms: [.macOS(.v14)],
    targets: [
        .target(name: "ArabesqueCore"),
        .target(name: "ArabesqueSystem"),
        .executableTarget(name: "ArabesqueTools", dependencies: ["ArabesqueSystem"]),
        .executableTarget(name: "ArabesqueApp", dependencies: ["ArabesqueCore", "ArabesqueSystem"]),
        .testTarget(name: "ArabesqueCoreTests", dependencies: ["ArabesqueCore"]),
        .testTarget(name: "ArabesqueSystemTests", dependencies: ["ArabesqueSystem"]),
    ]
)
