// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "RegularExpression",
    products: [
        .library(
            name: "RegularExpression",
            targets: ["RegularExpression"]),
    ],
    targets: [
        .target(
            name: "RegularExpression",
            dependencies: []),
        .testTarget(
            name: "RegularExpressionTests",
            dependencies: ["RegularExpression"]),
    ]
)
