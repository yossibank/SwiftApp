import Foundation

protocol GitHubRepositoryProtocol {
    func fetch(query: String) async throws -> [GitHubRepositoryEntity]
}

final class GitHubRepository: GitHubRepositoryProtocol {
    private let apiClient = APIClient()

    func fetch(query: String) async throws -> [GitHubRepositoryEntity] {
        let dto = try await apiClient.fetchRepositories(query: query)
        return dto.map(GitHubRepositoryMapper.map)
    }
}
