// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "OffScreen",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "OffScreenKit",
            targets: ["OffScreenKit"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "OffScreenKit",
            dependencies: [],
            path: "OffScreen",
            exclude: ["OffScreenApp.swift", "Info.plist"]
        ),
        .testTarget(
            name: "OffScreenKitTests",
            dependencies: ["OffScreenKit"],
            path: "Tests"
        )
    ]
)
