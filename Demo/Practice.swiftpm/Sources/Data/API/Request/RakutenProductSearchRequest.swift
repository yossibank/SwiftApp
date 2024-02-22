import Foundation

// https://webservice.rakuten.co.jp/explorer/api/IchibaItem/Search
struct RakutenProductSearchRequest: Request {
    typealias Response = RakutenProductSearchEntity
    typealias PathComponent = EmptyPathComponent

    struct Parameters: Encodable {
        let keyword: String
        let page: Int
        let hits: Int
        let formatVersion: Int
        let applicationId: String

        init(
            keyword: String,
            page: Int = 1,
            hits: Int = 30,
            formatVersion: Int = 2,
            applicationId: String = "1032211485929725116"
        ) {
            self.keyword = keyword
            self.page = page
            self.hits = hits
            self.formatVersion = formatVersion
            self.applicationId = applicationId
        }
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
