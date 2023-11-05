@testable import API
@testable import AppDomain
import XCTest

final class AppErrorTest: XCTestCase {
    func test_parse_receive_appError() {
        // arrange
        let error = AppError(apiError: .invalidRequest)

        // act
        let appError = AppError.parse(error)

        // assert
        XCTAssertEqual(
            appError.apiError,
            .invalidRequest
        )
    }

    func test_parse_receive_unknown_error() {
        // arrange
        let error = NSError(
            domain: NSURLErrorDomain,
            code: URLError.unknown.rawValue
        )

        // act
        let appError = AppError.parse(error)

        // assert
        XCTAssertEqual(
            appError.apiError,
            .unknown
        )
    }

    func test_decodeError_errorDescription() {
        // arrange
        let error = AppError(apiError: .decodeError)

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
        let error = AppError(apiError: .timeoutError)

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
        let error = AppError(apiError: .urlSessionError)

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
        let error = AppError(apiError: .emptyData)

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
        let error = AppError(apiError: .emptyResponse)

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
        let error = AppError(apiError: .invalidRequest)

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
        let error = AppError(apiError: .invalidStatusCode(500))

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
        let error = AppError(apiError: .unknown)

        // act
        let description = error.errorDescription

        // assert
        XCTAssertEqual(
            description,
            "不明エラー"
        )
    }
}
