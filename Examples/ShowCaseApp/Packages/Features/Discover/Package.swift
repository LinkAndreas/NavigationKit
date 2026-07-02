// swift-tools-version: 6.3.2

import PackageDescription

let package = Package(
    name: "Discover",
    platforms: [
        .iOS(.v26), .macOS(.v26)
    ],
    products: [
        .library(
            name: "Discover",
            targets: ["Discover"]
        ),
    ],
    dependencies: [
        .package(name: "NavigationKit", path: "../../../../../")
    ],
    targets: [
        .target(
            name: "Discover",
            dependencies: [
                .product(name: "NavigationKit", package: "NavigationKit")
            ],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ],
        ),
    ]
)
