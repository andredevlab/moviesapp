// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "Networking",
    platforms: [
        .iOS("26.6"),
        .macOS(.v13)
    ],
    products: [
        .library(name: "Networking", targets: ["Networking"]),
    ],
    dependencies: [
        .package(url: "https://github.com/hmlongco/Factory.git", from: "3.5.0")
    ],
    targets: [
        .target(name: "Networking",
                dependencies: [.product(name: "FactoryKit", package: "Factory")]),
        .testTarget(name: "NetworkingTests", dependencies: ["Networking"])
    ],
    swiftLanguageModes: [.v6]
)
