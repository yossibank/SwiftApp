import API

/// @mockable
public protocol AppErrorConverterInput {
    func convert(_ apiError: APIError) -> AppError
}

public struct AppErrorConverter: AppErrorConverterInput {
    public func convert(_ apiError: APIError) -> AppError {
        .init(apiError: apiError)
    }
}
