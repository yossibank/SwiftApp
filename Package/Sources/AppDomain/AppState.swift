import Foundation

public enum AppState<T> {
    case initial
    case loading
    case error
    case empty
    case loaded(T)
}
