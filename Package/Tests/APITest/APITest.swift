@testable import API
import XCTest

final class APITest: XCTestCase {
    private var apiClient: APIClient!

    override func setUp() {
        super.setUp()
        apiClient = .init()
    }

    override func tearDown() {
        super.tearDown()
        apiClient = nil
    }

    func test_sample() {
        XCTAssertEqual(apiClient.test(), "Test!!!")
    }
}
