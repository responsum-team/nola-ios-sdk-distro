// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ResChatHouUIKit",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ResChatHouUIKit",
            targets: ["ResChatHouUIKit"]),
    ],
    dependencies: [
        // Add reschatui, reschatSocket, ResChatAppearance, and ResChatHouCommon as local package dependencies
        .package(name: "reschatui", path: "../reschatui"),
        .package(name: "reschatSocket", path: "../reschatSocket"),
        .package(name: "ResChatAppearance", path: "../ResChatAppearance"),
        .package(name: "ResChatHouCommon", path: "../ResChatHouCommon")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ResChatHouUIKit",
            dependencies: ["reschatui", "reschatSocket", "ResChatAppearance", "ResChatHouCommon"]),
        .testTarget(
            name: "ResChatHouUIKitTests",
            dependencies: ["ResChatHouUIKit"]),
    ]
)
