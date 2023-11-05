// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// MARK: - Library

let ohHttpStubs = Target.Dependency.product(
    name: "OHHTTPStubsSwift",
    package: "OHHTTPStubs"
)

// MARK: - Macro

let codingKeys = Target.Dependency.product(
    name: "CodingKeys",
    package: "CodingKeysMacro"
)

let structBuilderMacro = Target.Dependency.product(
    name: "StructBuilder",
    package: "StructBuilderMacro"
)

// MARK: - Package

let appLogger = Target.target(
    name: "AppLogger"
)

let api = Target.target(
    name: "API",
    dependencies: [appLogger],
    dependenciesLibraries: [codingKeys, structBuilderMacro]
)

let pokemonData = Target.target(
    name: "PokemonData",
    dependencies: [api],
    dependenciesLibraries: [codingKeys, structBuilderMacro]
)

let appDomain = Target.target(
    name: "AppDomain",
    dependencies: [api]
)

let pokemonDomain = Target.target(
    name: "PokemonDomain",
    dependencies: [pokemonData],
    dependenciesLibraries: [structBuilderMacro]
)

let mock = Target.target(
    name: "Mock",
    dependencies: [api, pokemonData]
)

// MARK: - Test Package

let appLoggerTest = Target.testTarget(
    name: "AppLoggerTest",
    dependencies: [appLogger]
)

let apiTest = Target.testTarget(
    name: "APITest",
    dependencies: [api],
    dependenciesLibraries: [ohHttpStubs],
    resources: [.process("JSON")]
)

let pokemonDataTest = Target.testTarget(
    name: "PokemonDataTest",
    dependencies: [pokemonData, mock],
    dependenciesLibraries: [ohHttpStubs],
    resources: [.process("JSON")]
)

let appDomainTest = Target.testTarget(
    name: "AppDomainTest",
    dependencies: [appDomain]
)

let pokemonDomainTest = Target.testTarget(
    name: "PokemonDomainTest",
    dependencies: [pokemonDomain, mock]
)

// MARK: - Target

let package = Package.package(
    name: "Package",
    platforms: [
        .iOS(.v15)
    ],
    dependencies: [
        .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.52.4"),
        .package(url: "https://github.com/AliSoftware/OHHTTPStubs", from: "9.1.0"),
        .package(path: "../CodingKeysMacro"),
        .package(path: "../StructBuilderMacro")
    ],
    targets: [
        api,
        appDomain,
        appLogger,
        mock,
        pokemonData,
        pokemonDomain
    ],
    testTargets: [
        apiTest,
        appDomainTest,
        appLoggerTest,
        pokemonDataTest,
        pokemonDomainTest
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
        dependencies: [Target],
        dependenciesLibraries: [Target.Dependency] = [],
        resources: [Resource] = []
    ) -> Target {
        .testTarget(
            name: name,
            dependencies: dependencies.map(\.dependency) + dependenciesLibraries,
            resources: resources
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
