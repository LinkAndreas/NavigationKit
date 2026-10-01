// swift-tools-version: 6.3.2

import PackageDescription

let settings: [SwiftSetting] = [.enableUpcomingFeature("ApproachableConcurrency")]

let package = Package(
    name: "NavigationKit",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
    ],
    products: [
        .library(name: "NavigationKit", targets: ["NavigationKit"]),
        .library(name: "NavigationKitInterface", targets: ["NavigationKitInterface"]),
        .library(name: "NavigationKitTesting", targets: ["NavigationKitTesting"]),
        .library(name: "NavigationKitDebug", targets: ["NavigationKitDebug"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.4.0"),
    ],
    targets: [
        // Routes, Navigator, steps, dialogs — no SwiftUI. Feature view models and route
        // contract packages depend on this alone.
        .target(name: "NavigationKitInterface", swiftSettings: settings),

        // Containers, presentation, restoration. Re-exports NavigationKitInterface.
        .target(name: "NavigationKit", dependencies: ["NavigationKitInterface"], swiftSettings: settings),

        // RecordingNavigator for unit tests and previews.
        .target(name: "NavigationKitTesting", dependencies: ["NavigationKitInterface"], swiftSettings: settings),

        // Floating debugger overlay for DEBUG builds.
        .target(name: "NavigationKitDebug", dependencies: ["NavigationKit"], swiftSettings: settings),

        .testTarget(
            name: "NavigationKitTests",
            dependencies: ["NavigationKit", "NavigationKitTesting"],
            swiftSettings: settings
        ),
    ]
)
