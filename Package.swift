// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-receipt-parse",
    platforms: [
        .iOS(.v15),
        .macOS(.v14)
    ],
    products: [
        .library(name: "ReceiptParse", targets: ["Parse"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-asn1.git", from: "1.1.0")
    ],
    targets: [
        .target(
            name: "Parse",
            dependencies: [
                .product(name: "SwiftASN1", package: "swift-asn1")
            ]
        ),
        .testTarget(
            name: "ParseTests",
            dependencies: [
                .target(name: "Parse")
            ],
            resources: [.process("Resources")]
        ),
    ]
)
