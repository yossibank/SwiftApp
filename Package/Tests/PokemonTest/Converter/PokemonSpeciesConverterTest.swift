@testable import API
@testable import Pokemon
import XCTest

final class PokemonSpeciesConverterTest: XCTestCase {
    private var converter: PokemonSpeciesConverter!

    override func setUp() {
        super.setUp()

        converter = .init()
    }

    override func tearDown() {
        super.tearDown()

        converter = nil
    }

    func test_convert_pokemonSpeciesDataObject_to_pokemonSpeciesModelObject() {
        // arrange
        let input = PokemonSpeciesDataObjectBuilder(
            id: 1,
            isLegendary: false,
            names: [
                PokemonDataNameBuilder(
                    language: PokemonDataLanguageBuilder(
                        name: "ja",
                        url: "https://pokeapi.co/api/v2/language/11/"
                    ).build(),
                    name: "フシギダネ"
                ).build()
            ]
        ).build()

        // act
        let actual = converter.convert(input)

        // assert
        XCTAssertEqual(
            actual,
            PokemonSpeciesModelObjectBuilder(
                id: 1,
                isLegendary: false,
                japaneseName: "フシギダネ",
                names: [
                    PokemonModelNameBuilder(
                        language: PokemonModelLanguageBuilder(
                            name: "ja",
                            url: .init(string: "https://pokeapi.co/api/v2/language/11/")
                        ).build(),
                        name: "フシギダネ"
                    ).build()
                ]
            ).build()
        )
    }
}
