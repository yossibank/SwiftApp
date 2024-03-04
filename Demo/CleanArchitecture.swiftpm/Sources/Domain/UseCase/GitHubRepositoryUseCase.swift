import Foundation

protocol GithubRepositoryUseCaseProtocol {
    func execute(query: String) async throws -> [GitHubRepositoryEntity]
}

final class GitHubRepositoryUseCase: GithubRepositoryUseCaseProtocol {
    private let repository: GitHubRepositoryProtocol

    init(repository: GitHubRepositoryProtocol) {
        self.repository = repository
    }

    func execute(query: String) async throws -> [GitHubRepositoryEntity] {
        do {
            return try await repository.fetch(query: query)
        } catch {
            throw error
        }
    }
}
