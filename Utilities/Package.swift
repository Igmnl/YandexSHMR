// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Utilities",
    platforms: [.iOS(.v18)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PieChart",
            targets: ["PieChart"]),
        .library(
            name: "LaunchAnimation",
            targets: ["LaunchAnimation"]),
    ],
    dependencies: [
        .package(url: "https://github.com/airbnb/lottie-spm.git", from: "4.5.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PieChart",
            dependencies: [],
            path: "Sources/PieChart",
            publicHeadersPath: "Include"
        ),
        
        .target(
            name: "LaunchAnimation",
            dependencies: [
                .product(name: "Lottie", package: "lottie-spm")
            ],
            path: "Sources/LaunchAnimation",
            resources: [
                .process("Resources/launch-animation.json")
            ]),
    ]
)
