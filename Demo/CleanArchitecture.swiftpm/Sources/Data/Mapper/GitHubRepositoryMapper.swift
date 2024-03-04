import Foundation

struct GitHubRepositoryMapper {
    static func map(dto: GitHubRepositoryDTO.Item) -> GitHubRepositoryEntity {
        .init(
            id: dto.id,
            name: dto.name,
            description: dto.description
        )
    }
}
