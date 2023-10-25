// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "CodingKeys",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .macCatalyst(.v13)
    ],
    products: [
        .library(
            name: "CodingKeys",
            targets: ["CodingKeys"]
        ),
        .executable(
            name: "CodingKeysClient",
            targets: ["CodingKeysClient"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0")
    ],
    targets: [
        .macro(
            name: "CodingKeysMacro",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(
            name: "CodingKeys",
            dependencies: ["CodingKeysMacro"]
        ),
        .executableTarget(
            name: "CodingKeysClient",
            dependencies: ["CodingKeys"]
        ),
        .testTarget(
            name: "CodingKeysTests",
            dependencies: [
                "CodingKeysMacro",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
            ]
        )
    ]
)
