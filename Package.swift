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
        .package(url: "https://github.com/apple/swift-certificates.git", from: "1.2.0")
    ],
    targets: [
        .target(
            name: "Parse",
            dependencies: [
                .product(name: "X509", package: "swift-certificates")
            ],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "ParseTests",
            dependencies: [
                .target(name: "Parse")
            ],
            resources: [.process("Resources")]
        )
    ]
)
