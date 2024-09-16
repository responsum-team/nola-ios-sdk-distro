// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ResChatHouCommon",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ResChatHouCommon",
            targets: ["ResChatHouCommon"]),
    ],
    dependencies: [
        // Add reschatui, reschatSocket, and ResChatAppearance as local package dependencies
        .package(name: "ResChatAppearance", path: "../ResChatAppearance"),
        .package(name: "reschatSocket", path: "../reschatSocket"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ResChatHouCommon",
            dependencies: ["ResChatAppearance", "reschatSocket"]),
        .testTarget(
            name: "ResChatHouCommonuTests",
            dependencies: ["ResChatHouCommon"]),
    ]
)
