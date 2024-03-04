import Foundation

struct GitHubRepositoryEntity: Codable {
    let items: [Item]

    struct Item: Codable {
        let id: Int
        let name: String
        let description: String?
    }
}
