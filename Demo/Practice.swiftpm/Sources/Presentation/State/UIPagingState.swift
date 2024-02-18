import Foundation

enum UIPagingState<T: Equatable>: Equatable {
    case initial
    case loading(loaded: T)
    case initialError(AppError)
    case loadingError(AppError)
    case empty
    case loaded(T)
}
