@testable import API
@testable import Mock
import OHHTTPStubs
import OHHTTPStubsSwift
@testable import PokemonData
import XCTest

final class PokemonDataStoreTest: XCTestCase {
    private var apiClient: APIClientProtocolMock!
    private var dataStore: PokemonDataStore!

    override func setUp() {
        super.setUp()

        apiClient = .init()
        dataStore = .init(apiClient: apiClient)
    }

    override func tearDown() {
        super.tearDown()

        apiClient = nil
        dataStore = nil

        HTTPStubs.removeAllStubs()
    }

    func test_dataStore_fetch_pokemon() async throws {
        // arrange
        let entity = PokemonEntityBuilder(
            id: 1,
            name: "フシギダネ",
            isDefault: true,
            sprites: PokemonSpritesEntityBuilder(
                backDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/1.png",
                backFemale: nil,
                backShiny: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/shiny/1.png",
                backShinyFemale: nil,
                frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png",
                frontFemale: nil,
                frontShiny: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/1.png",
                frontShinyFemale: nil,
                other: PokemonOtherEntityBuilder(
                    dreamWorld: PokemonDreamWorldEntityBuilder(
                        frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/dream-world/1.svg",
                        frontFemale: nil
                    ).build(),
                    home: PokemonHomeEntityBuilder(
                        frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/1.png",
                        frontFemale: nil,
                        frontShiny: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/shiny/1.png",
                        frontShinyFemale: nil
                    ).build(),
                    officialArtwork: PokemonOfficialArtworkEntityBuilder(
                        frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png",
                        frontShiny: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/shiny/1.png"
                    ).build()
                ).build()
            ).build()
        ).build()

        apiClient.requestHandler = { request in
            XCTAssertTrue(request is PokemonRequest)
            return entity
        }

        // act
        let actual = try await dataStore.fetchPokemon(id: 1)

        // assert
        XCTAssertEqual(
            actual,
            entity
        )
    }

    func test_dataStore_fetch_pokemonSpecies() async throws {
        // arrange
        let entity = PokemonSpeciesEntityBuilder(
            id: 1,
            isLegendary: false,
            names: [
                PokemonNameEntityBuilder(
                    language: PokemonLanguageEntityBuilder(
                        name: "ja",
                        url: "https://pokeapi.co/api/v2/language/11/"
                    ).build(),
                    name: "フシギダネ"
                ).build()
            ]
        ).build()

        apiClient.requestHandler = { request in
            XCTAssertTrue(request is PokemonSpeciesRequest)
            return entity
        }

        // act
        let actual = try await dataStore.fetchSpeciesPokemon(id: 1)

        // assert
        XCTAssertEqual(
            actual,
            entity
        )
    }
}
