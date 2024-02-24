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

    func makeFloatingActionButtons() -> [FloatingActionButton] {
        let createButton: FloatingActionButton = .init(
            iconName: "plus",
            didTap: { [weak self] in
                self?.send(.create)
            }
        )

        let searchButton: FloatingActionButton = .init(
            iconName: "magnifyingglass",
            didTap: { [weak self] in
                self?.send(.search)
            }
        )

        return [searchButton, createButton]
    }

    func deleteItem(item: ProductModel) {
        state.itemList.removeAll { $0.id == item.id }

        dependency.userDefaultsClient.setValue(
            for: \.itemList,
            value: state.itemList
        )
    }
}

extension RootViewModel {
    struct State {
        var isSelectedButton = false
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
