import Foundation

public enum AppState<T> {
    case initial
    case loading
    case error(AppError)
    case empty
    case loaded(T)
}
