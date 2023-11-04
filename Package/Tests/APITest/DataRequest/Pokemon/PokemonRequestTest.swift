@testable import API
import OHHTTPStubs
import OHHTTPStubsSwift
import XCTest

final class PokemonRequestTest: XCTestCase {
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
        stub(condition: isPath("/api/v2/pokemon/1")) { _ in
            fixture(
                filePath: OHPathForFileInBundle(
                    "pokemon_success.json",
                    .module
                )!,
                headers: ["Content-Type": "application/json"]
            )
        }

        // act
        let response = try await apiClient.request(
            item: PokemonRequest(pathComponent: 1)
        )

        // assert
        XCTAssertEqual(response.id, 1)
        XCTAssertEqual(response.name, "bulbasaur")
        XCTAssertEqual(response.isDefault, true)
    }

    func test_receive_failure_decode_error() async throws {
        // arrange
        stub(condition: isPath("/api/v2/pokemon/1")) { _ in
            fixture(
                filePath: OHPathForFileInBundle(
                    "pokemon_failure_decode.json",
                    .module
                )!,
                headers: ["Content-Type": "application/json"]
            )
        }

        do {
            // act
            _ = try await apiClient.request(
                item: PokemonRequest(pathComponent: 1)
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
