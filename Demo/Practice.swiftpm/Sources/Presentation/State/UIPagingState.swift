import Foundation

enum UIPagingState<T: Equatable>: Equatable {
    case initial
    case loading(loaded: T)
    case error(AppError)
    case empty
    case loaded(T)
}
