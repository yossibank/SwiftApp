@testable import PokemonData
@testable import PokemonDomain
import XCTest

final class PokemonSpeciesTranslatorTest: XCTestCase {
    private var translator: PokemonSpeciesTranlator!

    override func setUp() {
        super.setUp()

        translator = .init()
    }

    override func tearDown() {
        super.tearDown()

        translator = nil
    }

    func test_translate_pokemonSpeciesEntity_to_pokemonSpeciesModel() {
        // arrange
        let entity = PokemonSpeciesEntityBuilder(
            id: 1,
            isLegendary: false,
            names: [
                PokemonNameEntityBuilder(
                    language: PokemonLanguageEntityBuilder(
                        name: "ja",
                        url:"https://pokeapi.co/api/v2/language/11/"
                    ).build(),
                    name: "フシギダネ"
                ).build()
            ]
        ).build()

        // act
        let actual = translator.translate(entity)

        // assert
        XCTAssertEqual(
            actual,
            PokemonSpeciesModelBuilder(
                id: 1,
                isLegendary: false,
                japaneseName: "フシギダネ",
                names: [
                    PokemonNameModelBuilder(
                        language:PokemonLanguageModelBuilder(
                            name: "ja",
                            url: .init(string:"https://pokeapi.co/api/v2/language/11/")
                        ).build(),
                        name: "フシギダネ"
                    ).build()
                ]
            ).build()
        )
    }
}
