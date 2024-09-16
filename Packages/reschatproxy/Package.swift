// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "reschatproxy",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "reschatproxy",
            targets: ["reschatproxy"]
        ),
    ],
    dependencies: [
        // Add reschatSocket as a local package dependency
        .package(name: "reschatSocket", path: "../reschatSocket"),
        // Add ResChatProtocols as a local package dependency
        .package(name: "ResChatProtocols", path: "../ResChatProtocols"),
    ],
    targets: [
        // Targets define the modules and test suites.
        .target(
            name: "reschatproxy",
            dependencies: [
                "reschatSocket",
                "ResChatProtocols" // Specify ResChatProtocols as a dependency
            ]
        ),
        .testTarget(
            name: "reschatproxyTests",
            dependencies: ["reschatproxy"]
        ),
    ]
)
