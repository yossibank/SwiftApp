import Foundation

struct GitHubRepositoryDTO: Codable {
    let items: [Item]

    struct Item: Codable {
        let id: Int
        let name: String
        let description: String?
    }
}
