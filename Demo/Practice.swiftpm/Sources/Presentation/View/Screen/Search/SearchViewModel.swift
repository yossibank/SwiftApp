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
            updateSearchState()

            guard !state.isEmptySearchEngine else {
                return
            }
        }

        state.isLoading = true

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
                updateSuccessState(items: newLoadedItems)
            } catch {
                updateFailureState(error: error)
            }
        }
    }

    func additionalLoadingItems(id: String) async {
        if state.loadedItems.last?.id == id {
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

    private func mixtureItems() {
        dependency.userDefaultsClient.value(for: \.$itemList)
            .sink { [weak self] itemList in
                guard let self else {
                    return
                }

                let updatedItems = state.loadedItems.map {
                    var item = $0
                    item.isAddedItem = itemList.contains { $0.id == item.id }
                    return item
                }

                state.loadedItems = updatedItems
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

    private func updateSearchState() {
        state.loadedItems = []
        state.currentRakutenPage = 1
        state.currentYahooStart = 1
        state.isEmptySearchEngine = state.searchEngines.isEmpty
    }

    private func updateSuccessState(items: [ProductModel]) {
        state.isLoading = false
        state.isShowToastError = false
        state.appError = nil
        state.isEmptyProduct = items.isEmpty
        state.loadedItems = items
    }

    private func updateFailureState(error: Error) {
        state.isLoading = false

        if state.loadedItems.isEmpty {
            state.appError = AppError.parse(error: error)
        } else {
            state.isShowToastError = true
        }
    }
}

extension SearchViewModel {
    struct State {
        var searchEngines: [ProductModel.SearchEngine] = [.rakuten, .yahoo]
        var isEmptySearchEngine = false
        var isEmptyProduct = false
        var isLoading = false
        var isShowToastError = false
        var keyword = ""
        var currentRakutenPage = 1
        var currentYahooStart = 1
        var loadedItems: [ProductModel] = []
        var appError: AppError?
    }

    struct Dependency {
        let apiClient: APIClient
        let userDefaultsClient: UserDefaultsClient
        let translator: ProductTranslator
    }

    enum Output {}
}
