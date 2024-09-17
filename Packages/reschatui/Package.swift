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
        .package(name: "ResChatAppearance", path: "../ResChatAppearance"),
        .package(name: "ResChatProtocols", path: "../ResChatProtocols"),
        .package(name: "ResChatAttributedText", path: "../ResChatAttributedText"),
        .package(name: "ResChatUICommon", path: "../ResChatUICommon")
    ],
    targets: [
        // Targets define the modules and test suites.
        .target(
            name: "reschatui",
            dependencies: [
                "ResChatAppearance",
                "ResChatProtocols",
                "ResChatAttributedText",
                "ResChatUICommon"
            ]),
        .testTarget(
            name: "reschatuiTests",
            dependencies: ["reschatui"]),
    ]
)
