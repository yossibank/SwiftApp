import Foundation

final class GitHubRepositoryModel {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetch(query: String) async throws -> [GitHubRepositoryEntity.Item] {
        do {
            return try await apiClient.fetch(query: query)
        } catch {
            throw error
        }
    }
}
