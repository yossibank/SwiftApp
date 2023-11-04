@testable import API
import OHHTTPStubs
import OHHTTPStubsSwift
import XCTest

final class PokemonSpeciesRequestTest: XCTestCase {
    private var apiClient: APIClient!

    override func setUp() {
        super.setUp()

        apiClient = .init()
    }

    override func tearDown() {
        super.tearDown()

        apiClient = nil

        HTTPStubs.removeAllStubs()
    }

    func test_receive_success_response() async throws {
        // arrange
        stub(condition: isPath("/api/v2/pokemon-species/1")) { _ in
            fixture(
                filePath: OHPathForFileInBundle(
                    "pokemon_species_success.json",
                    .module
                )!,
                headers: ["Conetnt-Type": "application/json"]
            )
        }

        // act
        let response = try await apiClient.request(
            item: PokemonSpeciesRequest(pathComponent: 1)
        )

        // assert
        XCTAssertEqual(response.id, 1)
        XCTAssertEqual(response.isLegendary, true)
        XCTAssertEqual(response.names.filter { $0.name == "フシギダネ" }.count, 2)
    }

    func test_receive_failure_decode_error() async throws {
        // arrange
        stub(condition: isPath("/api/v2/pokemon-species/1")) { _ in
            fixture(
                filePath: OHPathForFileInBundle(
                    "pokemon_species_failure_decode.json",
                    .module
                )!,
                headers: ["Content-Type": "application/json"]
            )
        }

        do {
            // act
            _ = try await apiClient.request(
                item: PokemonSpeciesRequest(pathComponent: 1)
            )
        } catch {
            // assert
            XCTAssertEqual(
                error as! APIError,
                .decodeError
            )
        }
    }
}
