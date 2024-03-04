import Foundation

protocol GithubRepositoryUseCaseProtocol {
    func fetch(query: String) async throws -> [GitHubRepositoryModel]
}

struct GitHubRepositoryUseCase: GithubRepositoryUseCaseProtocol {
    private let repository: GitHubRepositoryProtocol
    private let translator: GitHubRepositoryTranslatorProtocol

    init(
        repository: GitHubRepositoryProtocol,
        translator: GitHubRepositoryTranslatorProtocol
    ) {
        self.repository = repository
        self.translator = translator
    }

    func fetch(query: String) async throws -> [GitHubRepositoryModel] {
        do {
            let entity = try await repository.fetch(query: query)
            return entity.map { translator.translate(from: $0) }
        } catch {
            throw error
        }
    }
}
