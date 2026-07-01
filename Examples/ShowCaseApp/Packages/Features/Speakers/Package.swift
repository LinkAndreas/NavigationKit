// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "Speakers",
    platforms: [.iOS(.v27)],
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
