// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "Networking",
    platforms: [
        .iOS("26.6"),
        .macOS(.v13)
    ],
    products: [
        .library(name: "Networking", targets: ["Networking"])
    ],
    targets: [
        .target(name: "Networking"),
        .testTarget(name: "NetworkingTests", dependencies: ["Networking"])
    ],
    swiftLanguageModes: [.v6]
)
