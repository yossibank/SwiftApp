import API
import Foundation

public struct AppError: Error, Equatable {
    public let apiError: APIError

    public init(apiError: APIError) {
        self.apiError = apiError
    }
}

public extension AppError {
    static func parse(_ error: Error) -> AppError {
        guard let apiError = error as? APIError else {
            return .init(apiError: .unknown)
        }

        return .init(apiError: apiError)
    }
}

extension AppError: LocalizedError {
    public var errorDescription: String? {
        apiError.errorDescription
    }
}
