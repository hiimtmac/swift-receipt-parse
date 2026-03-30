// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let swiftSettings: [SwiftSetting] = [
    // https://github.com/apple/swift-evolution/blob/main/proposals/0335-existential-any.md
    .enableUpcomingFeature("ExistentialAny"),

    // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0444-member-import-visibility.md
    .enableUpcomingFeature("MemberImportVisibility"),

    // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0409-access-level-on-imports.md
    .enableUpcomingFeature("InternalImportsByDefault"),
]

let package = Package(
    name: "swift-receipt-parse",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
    ],
    products: [
        .library(name: "ReceiptParse", targets: ["Parse"]),
    ],
    traits: [
        .trait(name: "Verification", description: "Perform certificate verification"),
        .default(enabledTraits: [])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-certificates.git", from: "1.18.0"),
        .package(url: "https://github.com/apple/swift-crypto.git", from: "4.3.0"),
        .package(url: "https://github.com/apple/swift-asn1.git", from: "1.6.0"),
    ],
    targets: [
        .target(
            name: "Parse",
            dependencies: [
                .product(name: "X509", package: "swift-certificates", condition: .when(traits: ["Verification"])),
                .product(name: "Crypto", package: "swift-crypto", condition: .when(traits: ["Verification"])),
                .product(name: "_CryptoExtras", package: "swift-crypto", condition: .when(traits: ["Verification"])),
                .product(name: "SwiftASN1", package: "swift-asn1")
            ],
            resources: [.process("Resources")],
            swiftSettings: swiftSettings
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
