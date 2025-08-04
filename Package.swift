// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "swift-dynamic-list",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(name: "DynamicList", targets: ["DynamicList"]),
    ],
    targets: [
        .target(name: "DynamicList"),
        .testTarget(name: "DynamicListTests", dependencies: ["DynamicList"]),
    ],
)
