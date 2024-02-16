import Combine

@MainActor
final class SearchViewModel: BaseViewModel<SearchViewModel> {}

extension SearchViewModel {
    struct State {}
    struct Dependency: Sendable {}
    enum Output {}
}
