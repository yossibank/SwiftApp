// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let alamofire = Target.Dependency.product(
    name: "Alamofire",
    package: "Alamofire"
)

let structBuilderMacro = Target.Dependency.product(
    name: "StructBuilder",
    package: "StructBuilderMacro"
)

let api = Target.target(
    name: "API",
    dependenciesLibraries: [alamofire, structBuilderMacro]
)

let apiTest = Target.testTarget(
    name: "APITest",
    dependencies: [
        api
    ]
)

let package = Package.package(
    name: "Package",
    platforms: [
        .iOS(.v15)
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire", from: "5.8.0"),
        .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.52.4"),
        .package(path: "../StructBuilderMacro")
    ],
    targets: [
        api
    ],
    testTargets: [
        apiTest
    ]
)

extension Target {
    private var dependency: Target.Dependency {
        .target(
            name: name,
            condition: nil
        )
    }

    fileprivate func library(targets: [Target] = []) -> Product {
        .library(
            name: name,
            targets: [name] + targets.map(\.name)
        )
    }

    static func target(
        name: String,
        dependencies: [Target] = [],
        dependenciesLibraries: [Target.Dependency] = [],
        resources: [Resource] = []
    ) -> Target {
        .target(
            name: name,
            dependencies: dependencies.map(\.dependency) + dependenciesLibraries,
            resources: resources
        )
    }

    static func testTarget(
        name: String,
        dependencies: [Target]
    ) -> Target {
        .testTarget(
            name: name,
            dependencies: dependencies.map(\.dependency)
        )
    }
}

extension Package {
    static func package(
        name: String,
        platforms: [SupportedPlatform],
        dependencies: [Dependency] = [],
        targets: [Target],
        testTargets: [Target]
    ) -> Package {
        .init(
            name: name,
            platforms: platforms,
            products: targets.map { $0.library() },
            dependencies: dependencies,
            targets: targets + testTargets
        )
    }
}
