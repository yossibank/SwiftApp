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
            state.displayState = .initialLoading
            state.searchParameter.reset()

            if state.searchParameter.isEmptyEngine {
                state.displayState = .emptySearchEngine
                return
            }
        }

        var newItems: [ProductModel]

        for searchEngine in state.searchParameter.engines {
            do {
                switch searchEngine {
                case .rakuten:
                    let entity = try await dependency.apiClient.request(
                        item: RakutenProductSearchRequest(
                            parameters: .init(
                                keyword: state.searchParameter.keyword,
                                page: state.searchParameter.rakuten
                            )
                        )
                    )
                    state.searchParameter.update(engine: .rakuten)
                    newItems = dependency.translator.translate(entity)

                case .yahoo:
                    let entity = try await dependency.apiClient.request(
                        item: YahooProductSearchRequest(
                            parameters: .init(
                                query: state.searchParameter.keyword,
                                start: state.searchParameter.yahoo
                            )
                        )
                    )
                    state.searchParameter.update(engine: .yahoo)
                    newItems = dependency.translator.translate(entity)

                case .original:
                    newItems = []
                }

                let newLoadedItems = updateItems(
                    items: state.searchParameter.loadedItems + newItems
                ).removeDuplicates(keyPath: \.id)

                state.searchParameter.loadedItems = newLoadedItems

                if newLoadedItems.isEmpty {
                    state.displayState = .emptySearchItem
                } else {
                    state.displayState = .loaded(loaded: newLoadedItems)
                }
            } catch {
                if state.searchParameter.loadedItems.isEmpty {
                    state.displayState = .showError(
                        appError: AppError.parse(error: error)
                    )
                } else {
                    state.isShowToastError = true
                }
            }
        }
    }

    func additionalLoadingItems(id: String) async {
        if state.searchParameter.loadedItems.last?.id == id {
            await search(isAdditionalLoading: true)
        }
    }

    func select(engine: ProductModel.SearchEngine) {
        if state.searchParameter.engines.contains(engine) {
            state.searchParameter.engines.removeAll(where: { $0 == engine })
        } else {
            state.searchParameter.engines.append(engine)
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

                let updatedItems = state.searchParameter.loadedItems.map {
                    var item = $0
                    item.isAddedItem = itemList.contains { $0.id == item.id }
                    return item
                }

                state.searchParameter.loadedItems = updatedItems
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
        var displayState: DisplayState = .initial
        var searchParameter = SearchParameter()
        var isShowToastError = false

        enum DisplayState {
            case initial
            case initialLoading
            case emptySearchEngine
            case emptySearchItem
            case showError(appError: AppError)
            case loaded(loaded: [ProductModel])
        }

        struct SearchParameter {
            var engines: [ProductModel.SearchEngine] = [.yahoo, .rakuten]
            var keyword = ""
            var rakuten = 1
            var yahoo = 1
            var loadedItems: [ProductModel] = []

            var isEmptyEngine: Bool {
                engines.isEmpty
            }

            var isSelectedRakuten: Bool {
                engines.contains(.rakuten)
            }

            var isSelectedYahoo: Bool {
                engines.contains(.yahoo)
            }

            mutating func reset() {
                loadedItems = []
                rakuten = 1
                yahoo = 1
            }

            mutating func update(engine: ProductModel.SearchEngine) {
                switch engine {
                case .rakuten:
                    rakuten += 1

                case .yahoo:
                    yahoo += 20

                case .original:
                    break
                }
            }
        }
    }

    struct Dependency {
        let apiClient: APIClient
        let userDefaultsClient: UserDefaultsClient
        let translator: ProductTranslator
    }

    enum Output {}
}
