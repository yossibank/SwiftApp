import Foundation

struct SearchRepositoryRequest: APIRequestType {
    typealias Response = SearchRepositoryResponse

    var path: String {
        "/search/repositories"
    }

    var queryItems: [URLQueryItem]? {
        [
            .init(name: "q", value: "SwiftUI"),
            .init(name: "order", value: "desc")
        ]
    }
}
