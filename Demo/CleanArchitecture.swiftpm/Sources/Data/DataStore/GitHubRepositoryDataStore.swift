import Foundation

protocol GitHubRepositoryDataStoreProtocol {
    func fetch(query: String) async throws -> [GitHubRepositoryEntity.Item]
}

struct GitHubRepositoryDataStore: GitHubRepositoryDataStoreProtocol {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetch(query: String) async throws -> [GitHubRepositoryEntity.Item] {
        try await apiClient.fetch(query: query)
    }
}
