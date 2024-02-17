import Foundation

enum ViewState<T: Equatable>: Equatable {
    case initial
    case loading
    case error(AppError)
    case loaded(T)
}
