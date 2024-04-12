// swift-tools-version: 5.8

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import AppleProductTypes
import PackageDescription

let package = Package(
    name: "MVP",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        .iOSApplication(
            name: "MVP",
            targets: ["MVP"],
            bundleIdentifier: "yossibank-yahoo.co.jp.MVP",
            teamIdentifier: "6WHPY5MQSB",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .box),
            accentColor: .presetColor(.yellow),
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
            name: "MVP",
            path: "Sources",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
