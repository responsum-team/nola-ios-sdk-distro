// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "reschatSocket",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "reschatSocket",
            targets: ["reschatSocket"]),
    ],
    dependencies: [
        // Add the Socket.IO client dependency
        .package(url: "https://github.com/socketio/socket.io-client-swift.git", from: "16.0.1"),
    ],
    targets: [
        .target(
            name: "reschatSocket",
            dependencies: [
                .product(name: "SocketIO", package: "socket.io-client-swift")
            ]
        ),
        .testTarget(
            name: "reschatSocketTests",
            dependencies: ["reschatSocket"],
            resources: [
                .copy("DemoData") // Include resources from the "DemoData" folder in the test target
            ]
        )
    ]
)
