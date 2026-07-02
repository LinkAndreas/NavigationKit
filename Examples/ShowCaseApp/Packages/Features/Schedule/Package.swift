// swift-tools-version: 6.3.2

import PackageDescription

let package = Package(
    name: "Schedule",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v26)
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
