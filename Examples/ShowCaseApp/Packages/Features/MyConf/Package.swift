// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "MyConf",
    platforms: [
        .iOS(.v27)
    ],
    products: [
        .library(
            name: "MyConf",
            targets: ["MyConf"]
        ),
    ],
    dependencies: [
        .package(name: "NavigationKit", path: "../../../../../")
    ],
    targets: [
        .target(
            name: "MyConf",
            dependencies: [
                .product(name: "NavigationKit", package: "NavigationKit"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ]
        ),
    ]
)
