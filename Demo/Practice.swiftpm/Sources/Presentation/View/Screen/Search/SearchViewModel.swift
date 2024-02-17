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
                state.items = dependency.translator.translate(entity)
            } catch {
                print(error)
            }

        case [.yahoo]:
            do {
                let entity = try await dependency.apiClient.request(
                    item: YahooProductSearchRequest(
                        parameters: .init(query: state.keyword)
                    )
                )
                state.items = dependency.translator.translate(entity)
            } catch {
                print(error)
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
        var searchEngines = SearchEngine.allCases
        var isEmptySearchEngine = false
        var keyword = ""
        var items: [ProductModel] = []
    }

    struct Dependency: Sendable {
        let apiClient: APIClient
        let translator: ProductTranslator
    }

    enum Output {}
}
