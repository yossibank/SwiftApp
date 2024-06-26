// swift-tools-version: 5.8

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import AppleProductTypes
import PackageDescription

let package = Package(
    name: "MVVM",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        .iOSApplication(
            name: "MVVM",
            targets: ["MVVM"],
            bundleIdentifier: "yossibank.com.MVVM",
            teamIdentifier: "6WHPY5MQSB",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .bicycle),
            accentColor: .presetColor(.cyan),
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
            name: "MVVM",
            path: "Sources",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
