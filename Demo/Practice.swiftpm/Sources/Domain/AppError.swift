import Foundation

struct AppError: Error, Equatable {
    let apiError: APIError

    static func parse(error: Error) -> AppError {
        guard let appError = error as? APIError else {
            return .init(apiError: .unknown)
        }

        return .init(apiError: appError)
    }
}

extension AppError: LocalizedError {
    var errorDescription: String? {
        apiError.errorDescription
    }
}
