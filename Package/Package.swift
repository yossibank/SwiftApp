// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// MARK: - Library

let theComposableArchitecture = Target.Dependency.product(
    name: "ComposableArchitecture",
    package: "swift-composable-architecture"
)

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

let appResources = Target.target(
    name: "AppResources",
    resources: [
        .process("Images"),
        .process("Strings")
    ]
)

let utility = Target.target(
    name: "Utility",
    dependencies: [appResources]
)

let api = Target.target(
    name: "API",
    dependencies: [appLogger],
    dependenciesLibraries: [codingKeys, structBuilderMacro]
)

let appDomain = Target.target(
    name: "AppDomain",
    dependencies: [api]
)

let pokemonData = Target.target(
    name: "PokemonData",
    dependencies: [api],
    dependenciesLibraries: [codingKeys, structBuilderMacro]
)

let pokemonDomain = Target.target(
    name: "PokemonDomain",
    dependencies: [pokemonData, appDomain],
    dependenciesLibraries: [structBuilderMacro]
)

let pokemonPresentation = Target.target(
    name: "PokemonPresentation",
    dependencies: [pokemonDomain, appDomain, utility]
)

let pokemonBuilder = Target.target(
    name: "PokemonBuilder",
    dependencies: [pokemonData, pokemonDomain, pokemonPresentation]
)

let tca = Target.target(
    name: "TCA",
    dependenciesLibraries: [theComposableArchitecture]
)

let mock = Target.target(
    name: "Mock",
    dependencies: [api, pokemonData, pokemonDomain]
)

// MARK: - Test Package

let utilityTest = Target.testTarget(
    name: "UtilityTest",
    dependencies: [utility]
)

let apiTest = Target.testTarget(
    name: "APITest",
    dependencies: [api],
    dependenciesLibraries: [ohHttpStubs],
    resources: [.process("JSON")]
)

let appDomainTest = Target.testTarget(
    name: "AppDomainTest",
    dependencies: [appDomain]
)

let pokemonDataTest = Target.testTarget(
    name: "PokemonDataTest",
    dependencies: [pokemonData, mock],
    dependenciesLibraries: [ohHttpStubs],
    resources: [.process("JSON")]
)

let pokemonDomainTest = Target.testTarget(
    name: "PokemonDomainTest",
    dependencies: [pokemonDomain, mock]
)

let pokemonPresentationTest = Target.testTarget(
    name: "PokemonPresentationTest",
    dependencies: [pokemonPresentation, mock]
)

let tcaTest = Target.testTarget(
    name: "TCATest",
    dependencies: [tca]
)

// MARK: - Target

let package = Package.package(
    name: "Package",
    platforms: [
        .iOS(.v15)
    ],
    dependencies: [
        .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.52.4"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.5.0"),
        .package(url: "https://github.com/AliSoftware/OHHTTPStubs", from: "9.1.0"),
        .package(path: "../CodingKeysMacro"),
        .package(path: "../StructBuilderMacro")
    ],
    targets: [
        api,
        appDomain,
        appLogger,
        appResources,
        mock,
        pokemonBuilder,
        pokemonData,
        pokemonDomain,
        pokemonPresentation,
        tca,
        utility
    ],
    testTargets: [
        apiTest,
        appDomainTest,
        pokemonDataTest,
        pokemonDomainTest,
        pokemonPresentationTest,
        tcaTest,
        utilityTest
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
