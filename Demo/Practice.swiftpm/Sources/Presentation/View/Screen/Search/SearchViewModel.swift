import Combine

@MainActor
final class SearchViewModel: BaseViewModel<SearchViewModel> {
    private var cancellables = Set<AnyCancellable>()

    required init(
        state: State,
        dependency: Dependency
    ) {
        super.init(
            state: state,
            dependency: dependency
        )

        mixtureItems()
    }

    func search(isAdditionalLoading: Bool) async {
        if !isAdditionalLoading {
            state.loadedItems = []
            state.currentRakutenPage = 1
            state.currentYahooStart = 1
            state.isEmptySearchEngine = state.searchEngines.isEmpty

            guard !state.isEmptySearchEngine else {
                return
            }
        }

        state.viewState = .loading(loaded: state.loadedItems)

        var newItems: [ProductModel]

        for searchEngine in state.searchEngines {
            do {
                switch searchEngine {
                case .rakuten:
                    let entity = try await dependency.apiClient.request(
                        item: RakutenProductSearchRequest(
                            parameters: .init(
                                keyword: state.keyword,
                                page: state.currentRakutenPage
                            )
                        )
                    )
                    state.currentRakutenPage += 1
                    newItems = dependency.translator.translate(entity)

                case .yahoo:
                    let entity = try await dependency.apiClient.request(
                        item: YahooProductSearchRequest(
                            parameters: .init(
                                query: state.keyword,
                                start: state.currentYahooStart
                            )
                        )
                    )
                    state.currentYahooStart += 20
                    newItems = dependency.translator.translate(entity)

                case .original:
                    newItems = []
                }
                let newLoadedItems = updateItems(items: state.loadedItems + newItems).removeDuplicates(keyPath: \.id)
                state.loadedItems = newLoadedItems

                if newLoadedItems.isEmpty {
                    state.viewState = .empty
                } else {
                    state.viewState = .loaded(newLoadedItems)
                }
            } catch {
                if state.loadedItems.isEmpty {
                    state.viewState = .initialError(
                        AppError.parse(error: error)
                    )
                } else {
                    state.viewState = .loadingError(
                        AppError.parse(error: error)
                    )
                }
            }
        }
    }

    func additionalLoadingItems(id: String) async {
        if state.loadedItems.last?.id == id {
            state.lastItemId = id
            await search(isAdditionalLoading: true)
        }
    }

    func select(engine: ProductModel.SearchEngine) {
        if state.searchEngines.contains(engine) {
            state.searchEngines.removeAll(where: { $0 == engine })
        } else {
            state.searchEngines.append(engine)
        }
    }

    func save(_ item: ProductModel) {
        var itemList = dependency.userDefaultsClient.value(for: \.itemList)
        itemList.append(item)
        dependency.userDefaultsClient.setValue(for: \.itemList, value: itemList)
    }

    func resetLastItemID() {
        state.lastItemId = nil
    }

    private func mixtureItems() {
        dependency.userDefaultsClient.value(for: \.$itemList)
            .sink { [weak self] itemList in
                guard let self else {
                    return
                }

                if case let .loaded(items) = state.viewState {
                    let updatedItems = items.map {
                        var item = $0
                        item.isAddedItem = itemList.contains { $0.id == item.id }
                        return item
                    }
                    state.viewState = .loaded(updatedItems)
                }
            }
            .store(in: &cancellables)
    }

    private func updateItems(items: [ProductModel]) -> [ProductModel] {
        let itemList = dependency.userDefaultsClient.value(for: \.itemList)

        return items.map {
            var item = $0
            item.isAddedItem = itemList.contains { $0.id == item.id }
            return item
        }
    }
}

extension SearchViewModel {
    struct State {
        var viewState: UIPagingState<[ProductModel]> = .initial
        var loadedItems: [ProductModel] = []
        var searchEngines: [ProductModel.SearchEngine] = [.rakuten, .yahoo]
        var isEmptySearchEngine = false
        var keyword = ""
        var currentRakutenPage = 1
        var currentYahooStart = 1
        var lastItemId: String?
    }

    struct Dependency {
        let apiClient: APIClient
        let userDefaultsClient: UserDefaultsClient
        let translator: ProductTranslator
    }

    enum Output {}
}
