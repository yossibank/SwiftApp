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

        dependency.userDefaultsClient.value(for: \.$itemList)
            .receive(on: DispatchQueue.main)
            .assign(to: \.state.itemList, on: self)
            .store(in: &cancellables)
    }

    func didTapCreateButton() {
        send(.create)
    }

    func didTapSearchButton() {
        send(.search)
    }
}

extension RootViewModel {
    struct State {
        var itemList: [ProductModel] = []
    }

    struct Dependency {
        let userDefaultsClient: UserDefaultsClient
    }

    enum Output {
        case create
        case search
    }
}
