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
        guard let appError = error as? AppError else {
            return .init(apiError: .unknown)
        }

        return appError
    }
}

extension AppError: LocalizedError {
    public var errorDescription: String? {
        apiError.errorDescription
    }
}
