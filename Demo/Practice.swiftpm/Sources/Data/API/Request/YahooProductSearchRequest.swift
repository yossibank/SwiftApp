import Foundation

// https://developer.yahoo.co.jp/webapi/shopping/shopping/v3/itemsearch.html
struct YahooProductSearchRequest: Request {
    typealias Response = YahooProductSearchEntity
    typealias PathComponent = EmptyPathComponent

    struct Parameters: Encodable {
        let query: String
        let start: Int
        let results: Int
        let appId: String

        init(
            query: String,
            start: Int = 1,
            results: Int = 20,
            appId: String = "dj00aiZpPXdaSG0xQ1hhY1RhRiZzPWNvbnN1bWVyc2VjcmV0Jng9MGY-"
        ) {
            self.query = query
            self.start = start
            self.results = results
            self.appId = appId
        }
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
