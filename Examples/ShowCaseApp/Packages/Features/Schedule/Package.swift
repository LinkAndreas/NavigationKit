// swift-tools-version: 6.3.2

import PackageDescription

let package = Package(
    name: "Schedule",
    platforms: [
        .iOS(.v26), .macOS(.v26)
    ],
    products: [
        .library(
            name: "Schedule",
            targets: ["Schedule"]
        ),
    ],
    dependencies: [
        .package(name: "NavigationKit", path: "../../../../../")
    ],
    targets: [
        .target(
            name: "Schedule",
            dependencies: [
                .product(name: "NavigationKit", package: "NavigationKit"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ],
        ),
    ]
)
