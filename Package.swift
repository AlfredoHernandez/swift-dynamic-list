// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "swift-dynamic-list",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
        .tvOS(.v17),
    ],
    products: [
        .library(name: "DynamicList", targets: ["DynamicList"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/combine-schedulers.git", from: "1.0.3"),
    ],
    targets: [
        .target(
            name: "DynamicList",
            dependencies: [
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
            ],
            exclude: [
                "Documentation/",
            ],
        ),
        .testTarget(name: "DynamicListTests", dependencies: ["DynamicList"]),
    ],
)
