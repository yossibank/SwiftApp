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
        let entity = PokemonEntity.mock()

        // act
        let actual = translator.translate(entity)

        // assert
        XCTAssertEqual(
            actual,
            PokemonModel.mock()
        )
    }
}
