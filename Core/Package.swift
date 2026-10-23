// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "Core",
    platforms: [
        .iOS("26.6"),
        .macOS(.v13)
    ],
    products: [
        .library(name: "Core", targets: ["Core"])
    ],
    targets: [
        .target(name: "Core")
    ],
    swiftLanguageModes: [.v6]
)
