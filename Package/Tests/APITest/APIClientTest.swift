@testable import API
import OHHTTPStubs
import OHHTTPStubsSwift
import XCTest

private struct TestRequest: Request {
    typealias Response = [TestObject]
    typealias PathComponent = EmptyPathComponent

    struct Parameters: Encodable {
        let userId: Int?
    }

    var baseURL: String { "https://test.com" }
    var path: String { "/request" }
    var method: HTTPMethod { .get }

    let parameters: Parameters

    init(
        parameters: Parameters,
        pathComponent: PathComponent = .init()
    ) {
        self.parameters = parameters
    }
}

private struct TestObject: DataStructure {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

final class APIClientTest: XCTestCase {
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
        stub(condition: isPath("/request")) { _ in
            fixture(
                filePath: OHPathForFileInBundle(
                    "test_success.json",
                    .module
                )!,
                headers: ["Content-Type": "application/json"]
            )
        }

        // act
        let response = try await apiClient.request(
            item: TestRequest(parameters: .init(userId: 1))
        )

        // assert
        XCTAssertEqual(response.count, 100)
        XCTAssertEqual(response.first!.userId, 1)
    }

    func test_receive_failure_decode_error() async throws {
        // arrange
        stub(condition: isPath("/request")) { _ in
            fixture(
                filePath: OHPathForFileInBundle(
                    "test_failure_decode.json",
                    .module
                )!,
                headers: ["Content-Type": "application/json"]
            )
        }

        do {
            // act
            _ = try await apiClient.request(
                item: TestRequest(parameters: .init(userId: nil))
            )
        } catch {
            // assert
            XCTAssertEqual(
                error as! APIError,
                .decodeError
            )
        }
    }

    func test_receive_failure_300_unit_error() async throws {
        // arrange
        stub(condition: isPath("/request")) { _ in
            fixture(
                filePath: OHPathForFileInBundle(
                    "test_success.json",
                    .module
                )!,
                status: 302,
                headers: ["Content-Type": "application/json"]
            )
        }

        do {
            // act
            _ = try await apiClient.request(
                item: TestRequest(parameters: .init(userId: nil))
            )
        } catch {
            // assert
            XCTAssertEqual(
                error as! APIError,
                .invalidStatusCode(302)
            )
        }
    }

    func test_receive_failure_400_unit_error() async throws {
        // arrange
        stub(condition: isPath("/request")) { _ in
            fixture(
                filePath: OHPathForFileInBundle(
                    "test_success.json",
                    .module
                )!,
                status: 404,
                headers: ["Content-Type": "application/json"]
            )
        }

        do {
            // act
            _ = try await apiClient.request(
                item: TestRequest(parameters: .init(userId: nil))
            )
        } catch {
            // assert
            XCTAssertEqual(
                error as! APIError,
                .invalidStatusCode(404)
            )
        }
    }

    func test_receive_failure_500_unit_error() async throws {
        // arrange
        stub(condition: isPath("/request")) { _ in
            fixture(
                filePath: OHPathForFileInBundle(
                    "test_success.json",
                    .module
                )!,
                status: 500,
                headers: ["Content-Type": "application/json"]
            )
        }

        do {
            // act
            _ = try await apiClient.request(
                item: TestRequest(parameters: .init(userId: nil))
            )
        } catch {
            // assert
            XCTAssertEqual(
                error as! APIError,
                .invalidStatusCode(500)
            )
        }
    }

    func test_receive_failure_timeout_error() async throws {
        // arrange
        stub(condition: isPath("/request")) { _ in
            let error = NSError(
                domain: NSURLErrorDomain,
                code: URLError.timedOut.rawValue
            )
            return HTTPStubsResponse(error: error)
        }

        do {
            // act
            _ = try await apiClient.request(
                item: TestRequest(parameters: .init(userId: nil))
            )
        } catch {
            // assert
            XCTAssertEqual(
                error as! APIError,
                .timeoutError
            )
        }
    }

    func test_receive_failure_noConnectInternet_error() async throws {
        // arrange
        stub(condition: isPath("/request")) { _ in
            let error = NSError(
                domain: NSURLErrorDomain,
                code: URLError.notConnectedToInternet.rawValue
            )
            return HTTPStubsResponse(error: error)
        }

        do {
            // act
            _ = try await apiClient.request(
                item: TestRequest(parameters: .init(userId: nil))
            )
        } catch {
            // assert
            XCTAssertEqual(
                error as! APIError,
                .noConnectInternet
            )
        }
    }

    func test_receive_failure_unknown_error() async throws {
        // arrange
        stub(condition: isPath("/request")) { _ in
            let error = NSError(
                domain: NSURLErrorDomain,
                code: URLError.unknown.rawValue
            )
            return HTTPStubsResponse(error: error)
        }

        do {
            // act
            _ = try await apiClient.request(
                item: TestRequest(parameters: .init(userId: nil))
            )
        } catch {
            // assert
            XCTAssertEqual(
                error as! APIError,
                .unknown
            )
        }
    }
}
