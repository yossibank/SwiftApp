import Foundation

// https://webservice.rakuten.co.jp/explorer/api/IchibaItem/Search
struct RakutenProductSearchRequest: Request {
    typealias Response = RakutenProductSearchEntity
    typealias PathComponent = EmptyPathComponent

    struct Parameters: Encodable {
        let keyword: String
        let applicationId = "1032211485929725116"
        let formatVersion = 2
    }

    var baseURL: String { "https://app.rakuten.co.jp" }
    var path: String { "/services/api/IchibaItem/Search/20220601" }
    var method: HTTPMethod { .get }

    let parameters: Parameters

    init(
        parameters: Parameters,
        pathComponent: PathComponent = .init()
    ) {
        self.parameters = parameters
    }
}
