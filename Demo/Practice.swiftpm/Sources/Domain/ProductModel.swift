import Foundation

struct ProductModel: Codable, Hashable {
    let id: String
    let name: String
    let description: String
    let price: Int
    let imageUrl: URL?
}
