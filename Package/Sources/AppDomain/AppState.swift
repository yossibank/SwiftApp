import Foundation

public enum AppState<T: Equatable>: Equatable {
    case initial
    case loading
    case error(AppError)
    case loaded(T)
}
