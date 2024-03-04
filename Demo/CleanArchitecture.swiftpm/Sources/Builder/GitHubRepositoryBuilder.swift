import SwiftUI

protocol GitHubRepositoryBuilderProtocol {
    func build() -> GitHubRepositoryView
}

struct GitHubRepositoryBuilder: GitHubRepositoryBuilderProtocol {
    @MainActor func build() -> GitHubRepositoryView {
        let view = GitHubRepositoryView(
            viewModel: .init(
                useCase: GitHubRepositoryUseCase(
                    repository: GitHubRepository(
                        dataStore: GitHubRepositoryDataStore(
                            apiClient: APIClient()
                        )
                    ),
                    translator: GitHubRepositoryTranslator()
                )
            )
        )
        return view
    }
}
