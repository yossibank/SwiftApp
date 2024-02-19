import Combine

@MainActor
final class SearchViewModel: BaseViewModel<SearchViewModel> {
    enum SearchEngine: CaseIterable {
        case yahoo
        case rakuten
    }

    func search() async {
        state.loadedItems = []
        state.isEmptySearchEngine = state.searchEngines.isEmpty

        guard !state.isEmptySearchEngine else {
            return
        }

        state.viewState = .loading(loaded: state.loadedItems)

        var newItems: [ProductModel]

        for searchEngine in state.searchEngines {
            do {
                switch searchEngine {
                case .rakuten:
                    let entity = try await dependency.apiClient().request(
                        item: RakutenProductSearchRequest(
                            parameters: .init(keyword: state.keyword)
                        )
                    )
                    newItems = dependency.translator.translate(entity)

                case .yahoo:
                    let entity = try await dependency.apiClient().request(
                        item: YahooProductSearchRequest(
                            parameters: .init(query: state.keyword)
                        )
                    )
                    newItems = dependency.translator.translate(entity)
                }
                let newLoadedItems = state.loadedItems + newItems
                state.loadedItems.append(contentsOf: newLoadedItems)

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
                    state.viewState = .loaded(state.loadedItems)
                }
            }
        }
    }

    func select(engine: SearchEngine) {
        if state.searchEngines.contains(engine) {
            state.searchEngines.removeAll(where: { $0 == engine })
        } else {
            state.searchEngines.append(engine)
        }
    }
}

extension SearchViewModel {
    struct State {
        var viewState: UIPagingState<[ProductModel]> = .initial
        var loadedItems: [ProductModel] = []
        var searchEngines = SearchEngine.allCases
        var isEmptySearchEngine = false
        var keyword = ""
    }

    struct Dependency: Sendable {
        let apiClient: @Sendable () -> APIClient
        let userDefaultsClient: @Sendable () -> UserDefaultsClient
        let translator: ProductTranslator
    }

    enum Output {}
}
