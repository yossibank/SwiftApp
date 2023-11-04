@testable import API
@testable import Pokemon
import XCTest

final class PokemonConverterTest: XCTestCase {
    private var converter: PokemonConverter!

    override func setUp() {
        super.setUp()

        converter = .init()
    }

    override func tearDown() {
        super.tearDown()

        converter = nil
    }

    func test_convert_pokemonDataObject_to_pokemonModelObject() {
        // arrange
        let input = PokemonDataObjectBuilder(
            id: 1,
            name: "フシギダネ",
            isDefault: true,
            sprites: PokemonDataSpritesBuilder(
                backDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/1.png",
                backFemale: nil,
                backShiny: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/shiny/1.png",
                backShinyFemale: nil,
                frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png",
                frontFemale: nil,
                frontShiny: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/1.png",
                frontShinyFemale: nil,
                other: PokemonDataOtherBuilder(
                    dreamWorld: PokemonDataDreamWorldBuilder(
                        frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/dream-world/1.svg",
                        frontFemale: nil
                    ).build(),
                    home: PokemonDataHomeBuilder(
                        frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/1.png",
                        frontFemale: nil,
                        frontShiny: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/shiny/1.png",
                        frontShinyFemale: nil
                    ).build(),
                    officialArtwork: PokemonDataOfficialArtworkBuilder(
                        frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png",
                        frontShiny: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/shiny/1.png"
                    ).build()
                ).build()
            ).build()
        ).build()

        // act
        let actual = converter.convert(input)

        // assert
        XCTAssertEqual(
            actual,
            PokemonModelObjectBuilder(
                id: 1,
                name: "フシギダネ",
                artworkImageURL: .init(
                    string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png"
                ),
                sprites: PokemonModelSpritesBuilder(
                    backDefaultURL: .init(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/1.png"),
                    backFemaleURL: nil,
                    backShinyURL: .init(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/shiny/1.png"),
                    backShinyFemaleURL: nil,
                    frontDefaultURL: .init(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png"),
                    frontFemaleURL: nil,
                    frontShinyURL: .init(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/1.png"),
                    frontShinyFemaleURL: nil,
                    other: PokemonModelOtherBuilder(
                        dreamWorld: PokemonModelDreamWorldBuilder(
                            frontDefaultURL: .init(
                                string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/dream-world/1.svg"
                            ),
                            frontFemaleURL: nil
                        ).build(),
                        home: PokemonModelHomeBuilder(
                            frontDefaultURL: .init(
                                string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/1.png"
                            ),
                            frontFemaleURL: nil,
                            frontShinyURL: .init(
                                string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/shiny/1.png"
                            ),
                            frontShinyFemaleURL: nil
                        ).build(),
                        officialArtwork: PokemonModelOfficialArtworkBuilder(
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
