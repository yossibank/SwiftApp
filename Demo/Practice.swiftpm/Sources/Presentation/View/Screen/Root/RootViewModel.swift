import Combine

@MainActor
final class RootViewModel: BaseViewModel<RootViewModel> {
    func didTapCreateButton() {
        send(.create)
    }

    func didTapSearchButton() {
        send(.search)
    }
}

extension RootViewModel {
    struct State {}

    typealias Dependency = Void

    enum Output {
        case create
        case search
    }
}
