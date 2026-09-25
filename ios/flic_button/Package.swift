// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "flic_button",
    platforms: [
        .iOS("12.0")
    ],
    products: [
        .library(name: "flic-button", targets: ["flic_button"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .binaryTarget(
            name: "flic2lib",
            path: "Frameworks/flic2lib.xcframework"
        ),
        .target(
            name: "flic_button",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .target(name: "flic2lib")
            ],
            cSettings: [
                .headerSearchPath("include/flic_button")
            ]
        )
    ]
)
