import Foundation

// https://developer.yahoo.co.jp/webapi/shopping/shopping/v3/itemsearch.html
struct YahooProductSearchRequest: Request {
    typealias Response = YahooProductSearchEntity
    typealias PathComponent = EmptyPathComponent

    struct Parameters: Encodable {
        let query: String
        let appId = "dj00aiZpPXdaSG0xQ1hhY1RhRiZzPWNvbnN1bWVyc2VjcmV0Jng9MGY-"
    }

    var baseURL: String { "https://shopping.yahooapis.jp" }
    var path: String { "/ShoppingWebService/V3/itemSearch" }
    var method: HTTPMethod { .get }

    let parameters: Parameters

    init(
        parameters: Parameters,
        pathComponent: PathComponent = .init()
    ) {
        self.parameters = parameters
    }
}
