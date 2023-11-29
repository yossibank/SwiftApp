@testable import AppDomain
@testable import Mock
@testable import PokemonDomain
@testable import PokemonPresentation
import XCTest

@MainActor
final class PokemonViewModelTest: XCTestCase {
    private var useCase: PokemonUseCaseProtocolMock!
    private var viewModel: PokemonViewModel!

    override func setUp() {
        super.setUp()

        useCase = .init()
        viewModel = .init(useCase: useCase)
    }

    override func tearDown() {
        super.tearDown()

        useCase = nil
        viewModel = nil
    }

    func test_fetch_success() async {
        // arrange
        useCase.fetchPokemonHandler = { id in
            PokemonModel.mock(id: id)
        }

        // act
        await viewModel.fetch()

        // assert
        switch viewModel.state {
        case let .loaded(viewData):
            XCTAssertEqual(viewData.count, 151)
            XCTAssertEqual(viewData.first!.name, "フシギダネ1")
            XCTAssertEqual(viewData.last!.name, "フシギダネ151")
        default:
            XCTFail("failed to fetch")
        }
    }

    func test_fetch_failure() async {
        // arrange
        useCase.fetchPokemonHandler = { _ in
            throw AppError(apiError: .urlSessionError)
        }

        // act
        await viewModel.fetch()

        // assert
        XCTAssertEqual(
            viewModel.state,
            .error(.init(apiError: .urlSessionError))
        )
    }
}
