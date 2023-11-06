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
        let entity = PokemonSpeciesEntity.mock(id: 1)

        // act
        let actual = translator.translate(entity)

        // assert
        XCTAssertEqual(
            actual,
            PokemonSpeciesModel.mock(id: 1)
        )
    }
}
