// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "reschatui",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "reschatui",
            targets: ["reschatui"]),
    ],
    dependencies: [
        .package(name: "ResChatAppearance", path: "../ResChatAppearance"),  // Add ResChatAppearance as a local package
        .package(name: "ResChatProtocols", path: "../ResChatProtocols"),   // Add ResChatProtocols as a local package
        .package(name: "ResChatAttributedText", path: "../ResChatAttributedText")  // Add ResChatAttributedText as a local package
    ],
    targets: [
        // Targets define the modules and test suites.
        .target(
            name: "reschatui",
            dependencies: [

                "ResChatAppearance",  // Specify ResChatAppearance as a dependency
                "ResChatProtocols",   // Specify ResChatProtocols as a dependency
                "ResChatAttributedText"  // Specify ResChatAttributedText as a dependency
            ]),
        .testTarget(
            name: "reschatuiTests",
            dependencies: ["reschatui"]),
    ]
)
