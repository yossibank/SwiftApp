import Foundation

public enum APIError: Error, Equatable {
    case decodeError
    case timeoutError
    case urlSessionError
    case emptyData
    case emptyResponse
    case invalidRequest
    case invalidStatusCode(Int)
    case unknown
}

extension APIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .decodeError: "デコードエラー"
        case .timeoutError: "タイムアウトエラー"
        case .urlSessionError: "URLSessionエラー"
        case .emptyData: "空データ"
        case .emptyResponse: "空レスポンス"
        case .invalidRequest: "無効リクエスト"
        case let .invalidStatusCode(code): "無効ステータスコード: \(code.description)"
        case .unknown: "不明エラー"
        }
    }
}

public extension APIError {
    static func parse(_ error: Error) -> APIError {
        if error is DecodingError {
            return .decodeError
        }

        // タイムアウトエラーコード: -1001
        if error._code == -1001 {
            return .timeoutError
        }

        // URLSessionエラーコード: -1009
        if error._code == -1009 {
            return .urlSessionError
        }

        guard let apiError = error as? APIError else {
            return .unknown
        }

        return apiError
    }
}
