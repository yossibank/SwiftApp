import Foundation

struct ProductModel: Hashable, Codable, UserDefaultsCompatible {
    let id: String
    let name: String
    let description: String
    let price: String
    let imageUrl: URL?
    let searchEngine: SearchEngine
    var isAddedItem = false

    enum SearchEngine: String, CaseIterable, Codable {
        case yahoo
        case rakuten
        case original
    }
}
