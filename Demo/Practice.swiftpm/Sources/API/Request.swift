import Foundation

/// 渡すパラメータがない(空)ときに生成する構造体
struct EmptyParameters: Encodable, Equatable {}
/// 返ってくるレスポンスがない(空)ときに生成する構造体
struct EmptyResponse: Codable, Equatable {}
/// 渡すIDなどが必要ない(空)ときに生成する構造体
struct EmptyPathComponent {}

/// 標準的なHTTPMethodを表現したenum
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

/// APIに送信するために必要な情報で、それぞれの要素をまとめたプロトコル
protocol Request<Response> {
    // APIに送信する際にアプリ側から付与するためのパラメータ(body, queryItemsで使う)
    associatedtype Parameters: Encodable
    // APIから返ってきたレスポンスをアプリ側で表現するための受け皿
    associatedtype Response: Codable
    /// APIに送信する際にアプリ側から付与するための情報(商品番号やユーザー番号などのID)
    associatedtype PathComponent

    // 必須要素
    // ベースとなるURL(共通で複数の箇所で使われているURL)
    var baseURL: String { get }
    // ベースのURLの後のそれぞれの詳細を表すためのパス文字列
    var path: String { get }
    // どのHTTPMethodを使用するか
    var method: HTTPMethod { get }
    // 付与するパラメータ(Parametersを作成する)
    var parameters: Parameters { get }

    // オプション要素(デフォルト値あり)
    // 付与するボディ(Parametersを作成する)
    var body: Data? { get }
    // タイムアウトが発生するまでの時間設定
    var timeoutInterval: TimeInterval { get }
    // 付与するヘッダー
    var headers: [String: String] { get }
    // 付与するクエリ
    var queryItems: [URLQueryItem]? { get }

    init(
        parameters: Parameters,
        pathComponent: PathComponent
    )
}

// 処理が共通している部分はextensionで大元で記載しておく
extension Request {
    var timeoutInterval: TimeInterval {
        10.0
    }

    var body: Data? {
        method == .get
            ? nil
            : try? JSONEncoder().encode(parameters)
    }

    var headers: [String: String] {
        var dic: [String: String] = [:]

        APIRequestHeader.allCases.forEach {
            dic[$0.rawValue] = $0.value
        }

        return dic
    }

    var queryItems: [URLQueryItem]? {
        let query: [URLQueryItem]

        if let p = parameters as? [Encodable] {
            query = p.flatMap { param in
                param.dictionary.map { key, value in
                    URLQueryItem(
                        name: key,
                        value: value?.description ?? ""
                    )
                }
            }
        } else {
            query = parameters.dictionary.map { key, value in
                URLQueryItem(
                    name: key,
                    value: value?.description ?? ""
                )
            }
        }

        let queryItems = query.sorted { first, second in
            first.name < second.name
        }

        return method == .get
            ? queryItems
            : nil
    }
}

extension Request where Parameters == EmptyParameters {
    init(pathComponent: PathComponent) {
        self.init(
            parameters: .init(),
            pathComponent: pathComponent
        )
    }
}

extension Request where PathComponent == EmptyPathComponent {
    init(parameters: Parameters) {
        self.init(
            parameters: parameters,
            pathComponent: .init()
        )
    }
}

private extension Encodable {
    var dictionary: [String: CustomStringConvertible?] {
        // JSONEncoder().encode(self) → Encodableに準拠されたデータ自身をJSONに変換する
        // JSONSerialization.jsonObject(with:) → JSONを辞書型に変換する
        (
            try? JSONSerialization.jsonObject(
                with: JSONEncoder().encode(self)
            )
        ) as? [String: CustomStringConvertible?] ?? [:]
    }
}
