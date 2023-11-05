@testable import Mock
@testable import PokemonData
@testable import PokemonDomain
import XCTest

final class PokemonUseCaseTest: XCTestCase {
    private var repository: PokemonRepositoryProtocolMock!
    private var translator: PokemonTranslatorProtocolMock!
    private var useCase: PokemonUseCase!

    override func setUp() {
        super.setUp()

        repository = .init()
        translator = .init()
        useCase = .init(
            repository: repository,
            translator: translator
        )
    }

    override func tearDown() {
        super.tearDown()

        repository = nil
        translator = nil
        useCase = nil
    }

    func test_fetch_pokemon() async throws {
        // arrange
        let entity = PokemonEntity.mock()
        let model = PokemonModel.mock()

        repository.fetchPokemonHandler = { id in
            XCTAssertEqual(id, 1)
            return entity
        }

        translator.translateHandler = { _ in
            model
        }

        // act
        let actual = try await useCase.fetchPokemon(id: 1)

        // assert
        XCTAssertEqual(
            actual,
            model
        )
    }
}
