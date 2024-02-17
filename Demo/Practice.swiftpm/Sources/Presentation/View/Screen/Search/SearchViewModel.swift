import Combine

@MainActor
final class SearchViewModel: BaseViewModel<SearchViewModel> {
    enum SearchEngine: CaseIterable {
        case yahoo
        case rakuten
    }

    func search() async {
        state.isEmptySearchEngine = state.searchEngines.isEmpty

        guard !state.isEmptySearchEngine else {
            return
        }

        switch state.searchEngines {
        case [.rakuten, .yahoo]:
            print("LP")

        case [.rakuten]:
            do {
                let entity = try await dependency.apiClient.request(
                    item: RakutenProductSearchRequest(
                        parameters: .init(keyword: state.keyword)
                    )
                )
                state.viewState = .loaded(
                    dependency.translator.translate(entity)
                )
            } catch {
                state.viewState = .error(
                    AppError.parse(error: error)
                )
            }

        case [.yahoo]:
            do {
                let entity = try await dependency.apiClient.request(
                    item: YahooProductSearchRequest(
                        parameters: .init(query: state.keyword)
                    )
                )
                state.viewState = .loaded(
                    dependency.translator.translate(entity)
                )
            } catch {
                state.viewState = .error(
                    AppError.parse(error: error)
                )
            }

        default:
            break
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
        var viewState: ViewState<[ProductModel]> = .initial
        var searchEngines = SearchEngine.allCases
        var isEmptySearchEngine = false
        var keyword = ""
    }

    struct Dependency: Sendable {
        let apiClient: APIClient
        let translator: ProductTranslator
    }

    enum Output {}
}
