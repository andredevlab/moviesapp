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
    dependencies: [
        .package(path: "../Networking"),
        .package(url: "https://github.com/hmlongco/Factory.git", from: "3.5.0")
    ],
    targets: [
        .target(name: "Core", dependencies: [
            .product(name: "Networking", package: "Networking"),
            .product(name: "FactoryKit", package: "Factory")
        ]),
        .testTarget(name: "CoreTests",
                    dependencies: ["Core", .product(name: "Networking", package: "Networking")],
                    resources: [.copy("Vendor/JSON")])
    ],
    swiftLanguageModes: [.v6]
)
