@testable import API
import XCTest

final class APIErrorTest: XCTestCase {
    func test_decodeError_errorDescription() {
        // arrange
        let error = APIError.decodeError

        // act
        let description = error.errorDescription

        // assert
        XCTAssertEqual(
            description,
            "デコードエラー"
        )
    }

    func test_timeoutError_errorDescription() {
        // arrange
        let error = APIError.timeoutError

        // act
        let description = error.errorDescription

        // assert
        XCTAssertEqual(
            description,
            "タイムアウトエラー"
        )
    }

    func test_urlSessionError_errorDescription() {
        // arrange
        let error = APIError.urlSessionError

        // act
        let description = error.errorDescription

        // assert
        XCTAssertEqual(
            description,
            "URLSessionエラー"
        )
    }

    func test_emptyData_errorDescription() {
        // arrange
        let error = APIError.emptyData

        // act
        let description = error.errorDescription

        // assert
        XCTAssertEqual(
            description,
            "空データ"
        )
    }

    func test_emptyResponse_errorDescription() {
        // arrange
        let error = APIError.emptyResponse

        // act
        let description = error.errorDescription

        // assert
        XCTAssertEqual(
            description,
            "空レスポンス"
        )
    }

    func test_invalidRequest_errorDescription() {
        // arrange
        let error = APIError.invalidRequest

        // act
        let description = error.errorDescription

        // assert
        XCTAssertEqual(
            description,
            "無効リクエスト"
        )
    }

    func test_invalidStatusCode_errorDescription() {
        // arrange
        let error = APIError.invalidStatusCode(500)

        // act
        let description = error.errorDescription

        // assert
        XCTAssertEqual(
            description,
            "無効ステータスコード: 500"
        )
    }

    func test_unknown_errorDescription() {
        // arrange
        let error = APIError.unknown

        // act
        let description = error.errorDescription

        // assert
        XCTAssertEqual(
            description,
            "不明エラー"
        )
    }
}
