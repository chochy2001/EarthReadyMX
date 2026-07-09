// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "EarthReadyCore",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "EarthReadyCore",
            targets: ["EarthReadyCore"]
        )
    ],
    targets: [
        .target(
            name: "EarthReadyCore",
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(
            name: "EarthReadyCoreTests",
            dependencies: ["EarthReadyCore"],
            swiftSettings: [.swiftLanguageMode(.v6)]
        )
    ]
)
