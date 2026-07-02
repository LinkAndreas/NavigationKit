// swift-tools-version: 6.3.2

import PackageDescription

let package = Package(
    name: "Account",
    platforms: [
        .iOS(.v26), .macOS(.v26)
    ],
    products: [
        .library(
            name: "Account",
            targets: ["Account"]
        ),
    ],
    dependencies: [
        .package(name: "NavigationKit", path: "../../../../../")
    ],
    targets: [
        .target(
            name: "Account",
            dependencies: [
                .product(name: "NavigationKit", package: "NavigationKit"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ],
        ),
    ]
)
