@testable import API
@testable import Model
import XCTest

final class AppErrorConverterTest: XCTestCase {
    private var converter: AppErrorConverter!

    override func setUp() {
        super.setUp()

        converter = .init()
    }

    override func tearDown() {
        super.tearDown()

        converter = nil
    }

    func test_convert_apiError_to_appError() {
        // arrange
        let input = APIError.invalidRequest

        // act
        let actual = converter.convert(input)

        // assert
        XCTAssertEqual(
            actual,
            .init(apiError: .invalidRequest)
        )
    }
}
