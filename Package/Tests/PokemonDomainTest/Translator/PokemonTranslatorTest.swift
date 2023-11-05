@testable import PokemonData
@testable import PokemonDomain
import XCTest

final class PokemonTranslatorTest: XCTestCase {
    private var translator: PokemonTranslator!

    override func setUp() {
        super.setUp()

        translator = .init()
    }

    override func tearDown() {
        super.tearDown()

        translator = nil
    }

    func test_translate_pokemonEntity_to_pokemonModel() {
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

        // act
        let actual = translator.translate(entity)

        // assert
        XCTAssertEqual(
            actual,
            PokemonModelBuilder(
                id: 1,
                name: "フシギダネ",
                imageURL: .init(
                    string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png"
                ),
                sprites: PokemonSpritesModelBuilder(
                    backDefaultURL: .init(
                        string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/1.png"
                    ),
                    backFemaleURL: nil,
                    backShinyURL: .init(
                        string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/shiny/1.png"
                    ),
                    backShinyFemaleURL: nil,
                    frontDefaultURL: .init(
                        string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png"
                    ),
                    frontFemaleURL: nil,
                    frontShinyURL: .init(
                        string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/1.png"
                    ),
                    frontShinyFemaleURL: nil,
                    other: PokemonOtherModelBuilder(
                        dreamWorld: PokemonDreamWorldModelBuilder(
                            frontDefaultURL: .init(
                                string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/dream-world/1.svg"
                            ),
                            frontFemaleURL: nil
                        ).build(),
                        home: PokemonHomeModelBuilder(
                            frontDefaultURL: .init(
                                string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/1.png"
                            ),
                            frontFemaleURL: nil,
                            frontShinyURL: .init(
                                string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/shiny/1.png"
                            ),
                            frontShinyFemaleURL: nil
                        ).build(),
                        officialArtwork: PokemonOfficialArtworkModelBuilder(
                            frontDefaultURL: .init(
                                string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png"
                            ),
                            frontShinyURL: .init(
                                string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/shiny/1.png"
                            )
                        ).build()
                    ).build()
                ).build()
            ).build()
        )
    }
}
