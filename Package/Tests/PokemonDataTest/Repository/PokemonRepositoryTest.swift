@testable import Mock
@testable import PokemonData
import XCTest

final class PokemonRepositoryTest: XCTestCase {
    private var dataStore: PokemonDataStoreProtocolMock!
    private var repository: PokemonRepository!

    override func setUp() {
        super.setUp()

        dataStore = .init()
        repository = .init(dataStore: dataStore)
    }

    override func tearDown() {
        super.tearDown()

        dataStore = nil
        repository = nil
    }

    func test_repository_fetch_pokemon() async throws {
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

        dataStore.fetchPokemonHandler = { id in
            XCTAssertEqual(id, 100)
            return entity
        }

        // act
        let actual = try await repository.fetchPokemon(id: 100)

        // assert
        XCTAssertEqual(
            actual,
            entity
        )
    }

    func test_repository_fetch_pokemonSpecies() async throws {
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

        dataStore.fetchSpeciesPokemonHandler = { id in
            XCTAssertEqual(id, 100)
            return entity
        }

        // act
        let actual = try await repository.fetchSpeciesPokemon(id: 100)

        // assert
        XCTAssertEqual(
            actual,
            entity
        )
    }
}
