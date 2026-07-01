// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "NavigationKit",
    platforms: [
        .iOS(.v27)
    ],
    products: [
        .library(name: "NavigationKit", targets: ["NavigationKit"]),
        .library(name: "NavigationKitDebug", targets: ["NavigationKitDebug"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.4.0"),
    ],
    targets: [
        // NavigationKit
        .target(
            name: "NavigationKit",
            swiftSettings: [.enableUpcomingFeature("ApproachableConcurrency")]
        ),
        .testTarget(
            name: "NavigationKitTests",
            dependencies: ["NavigationKit"],
            swiftSettings: [.enableUpcomingFeature("ApproachableConcurrency")]
        ),
        
        // NavigationKitDebug
        .target(
            name: "NavigationKitDebug",
            dependencies: ["NavigationKit"],
            swiftSettings: [.enableUpcomingFeature("ApproachableConcurrency")]
        ),
    ]
)
