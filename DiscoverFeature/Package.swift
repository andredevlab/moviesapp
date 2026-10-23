// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "DiscoverFeature",
    platforms: [
        .iOS("26.6"),
        .macOS(.v14)
    ],
    products: [
        .library(name: "DiscoverFeature", targets: ["DiscoverFeature"])
    ],
    dependencies: [
        .package(path: "../Core"),
        .package(path: "../Networking"),
        .package(url: "https://github.com/hmlongco/Factory.git", from: "3.5.0")
    ],
    targets: [
        .target(name: "DiscoverFeature", dependencies: [
            .product(name: "Core", package: "Core"),
            .product(name: "Networking", package: "Networking"),
            .product(name: "FactoryKit", package: "Factory")
        ]),
        .testTarget(name: "DiscoverFeatureTests", dependencies: [
            "DiscoverFeature",
            .product(name: "Core", package: "Core"),
            .product(name: "Networking", package: "Networking")
        ], resources: [.copy("Vendor/JSON")])
    ],
    swiftLanguageModes: [.v6]
)
