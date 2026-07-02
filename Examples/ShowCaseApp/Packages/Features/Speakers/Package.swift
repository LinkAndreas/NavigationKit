// swift-tools-version: 6.3.2

import PackageDescription

let package = Package(
    name: "Speakers",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(
            name: "Speakers",
            targets: ["Speakers"]
        ),
    ],
    dependencies: [
        .package(name: "NavigationKit", path: "../../../../../")
    ],
    targets: [
        .target(
            name: "Speakers",
            dependencies: ["NavigationKit"],
            resources: [
                .process("Resources/Media.xcassets")
            ]
        )
    ]
)
