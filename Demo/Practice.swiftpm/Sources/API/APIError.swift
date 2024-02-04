import Foundation

/// APIにリクエストを送信して、エラーが返ってきた際にどのようなエラーなのかを判定するためのenum
enum APIError: Error, Equatable {
    case decodeError
    case timeoutError
    case noConnectInternet
    case emptyData
    case emptyResponse
    case invalidRequest
    case invalidStatusCode(Int)
    case unknown
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .decodeError: "デコードエラー"
        case .timeoutError: "タイムアウトエラー"
        case .noConnectInternet: "インターネット通信エラー"
        case .emptyData: "空データ"
        case .emptyResponse: "空レスポンス"
        case .invalidRequest: "無効リクエスト"
        case let .invalidStatusCode(code): "無効ステータスコード: \(code)"
        case .unknown: "不明エラー"
        }
    }
}

extension APIError {
    /// APIから返ってくる際のエラーの型はErrorのためAPIErrorに変換する
    static func parse(_ error: Error) -> APIError {
        if error is DecodingError {
            return .decodeError
        }

        // -1001エラー
        // https://developer.apple.com/documentation/foundation/1508628-url_loading_system_error_codes/nsurlerrortimedout
        if error._code == NSURLErrorTimedOut {
            return .timeoutError
        }

        // -1009エラー
        // https://developer.apple.com/documentation/foundation/1508628-url_loading_system_error_codes/nsurlerrornotconnectedtointernet
        if error._code == NSURLErrorNotConnectedToInternet {
            return .noConnectInternet
        }

        guard let apiError = error as? APIError else {
            return .unknown
        }

        return apiError
    }
}
