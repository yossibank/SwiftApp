// swift-tools-version: 5.8

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import AppleProductTypes
import PackageDescription

let package = Package(
    name: "Flux",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        .iOSApplication(
            name: "Flux",
            targets: ["Flux"],
            bundleIdentifier: "yossibank-yahoo.co.jp.Flux",
            teamIdentifier: "6WHPY5MQSB",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .cat),
            accentColor: .presetColor(.brown),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "Flux",
            path: "Sources",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
