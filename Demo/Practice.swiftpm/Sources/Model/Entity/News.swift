import Foundation

struct News: Codable, Hashable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

struct Article: Codable, Hashable {
    let source: Source
    let author: String?
    let title: String
    let description: String?
    let publishedAt: String
    let urlToImage: String?

    struct Source: Codable, Hashable {
        let id: String?
    }
}
