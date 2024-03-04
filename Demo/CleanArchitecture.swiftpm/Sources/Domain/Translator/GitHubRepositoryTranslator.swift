import Foundation

protocol GitHubRepositoryTranslatorProtocol {
    func translate(from entity: GitHubRepositoryEntity.Item) -> GitHubRepositoryModel
}

struct GitHubRepositoryTranslator: GitHubRepositoryTranslatorProtocol {
    func translate(from entity: GitHubRepositoryEntity.Item) -> GitHubRepositoryModel {
        .init(
            id: entity.id,
            name: entity.name,
            description: entity.description
        )
    }
}
