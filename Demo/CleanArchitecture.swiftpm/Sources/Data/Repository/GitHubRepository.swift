import Foundation

protocol GitHubRepositoryProtocol {
    func fetch(query: String) async throws -> [GitHubRepositoryEntity.Item]
}

struct GitHubRepository: GitHubRepositoryProtocol {
    private let dataStore: GitHubRepositoryDataStore

    init(dataStore: GitHubRepositoryDataStore) {
        self.dataStore = dataStore
    }

    func fetch(query: String) async throws -> [GitHubRepositoryEntity.Item] {
        try await dataStore.fetch(query: query)
    }
}
