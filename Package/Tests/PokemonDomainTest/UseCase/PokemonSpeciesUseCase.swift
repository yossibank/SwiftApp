@testable import Mock
@testable import PokemonData
@testable import PokemonDomain
import XCTest

final class PokemonSpeciesUseCaseTest: XCTestCase {
    private var repository: PokemonRepositoryProtocolMock!
    private var translator: PokemonSpeciesTranslatorProtocolMock!
    private var useCase: PokemonSpeciesUseCase!

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
        let entity = PokemonSpeciesEntity.mock(id: 1)
        let model = PokemonSpeciesModel.mock(id: 1)

        repository.fetchSpeciesPokemonHandler = { id in
            XCTAssertEqual(id, 1)
            return entity
        }

        translator.translateHandler = { _ in
            model
        }

        // act
        let actual = try await useCase.fetchPokemonSpecies(id: 1)

        // assert
        XCTAssertEqual(
            actual,
            model
        )
    }
}
