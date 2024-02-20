import Combine
import Foundation

@MainActor
final class RootViewModel: BaseViewModel<RootViewModel> {
    private var cancellables = Set<AnyCancellable>()

    required init(
        state: State,
        dependency: Dependency
    ) {
        super.init(
            state: state,
            dependency: dependency
        )
    }

    func didTapCreateButton() {
        send(.create)
    }

    func didTapSearchButton() {
        send(.search)
    }
}

extension RootViewModel {
    struct State {}

    struct Dependency {
        let userDefaultsClient: UserDefaultsClient
    }

    enum Output {
        case create
        case search
    }
}
