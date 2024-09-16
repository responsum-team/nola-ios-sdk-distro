// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "ResChatSocketSDK",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "ResChatSocketSDK",
            targets: ["ResChatSocketSDK"]),
    ],
    dependencies: [
        .package(path: "./Packages/ResChatAppearance"),
        .package(path: "./Packages/ResChatAttributedText"),
        .package(path: "./Packages/ResChatHouCommon"),
        .package(path: "./Packages/ResChatHouUIKit"),
        .package(path: "./Packages/ResChatProtocols"),
        .package(path: "./Packages/reschatSocket"),
        .package(path: "./Packages/reschatproxy"),
        .package(path: "./Packages/reschatui"),
    ],
    targets: [
        .target(
            name: "ResChatSocketSDK",
            dependencies: [
                "ResChatAppearance",
                "ResChatAttributedText",
                "ResChatHouCommon",
                "ResChatHouUIKit",
                "ResChatProtocols",
                "reschatSocket",
                "reschatproxy",
                "reschatui"
            ]),
        .testTarget(
            name: "ResChatSocketSDKTests",
            dependencies: ["ResChatSocketSDK"]),
    ]
)
