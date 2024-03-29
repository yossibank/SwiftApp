import Foundation

public struct EmptyParameters: Encodable, Equatable {}
public struct EmptyResponse: Codable, Equatable {}
public struct EmptyPathComponent {}

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

public protocol Request<Response> {
    associatedtype Parameters: Encodable
    associatedtype Response: Codable
    associatedtype PathComponent

    // 必須要素
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters { get }

    // オプション要素(デフォルト値あり)
    var timeoutInterval: TimeInterval { get }
    var body: Data? { get }
    var headers: [String: String] { get }
    var queryItems: [URLQueryItem]? { get }

    init(
        parameters: Parameters,
        pathComponent: PathComponent
    )
}

public extension Request {
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

public extension Request where Parameters == EmptyParameters {
    init(pathComponent: PathComponent) {
        self.init(
            parameters: .init(),
            pathComponent: pathComponent
        )
    }
}

public extension Request where PathComponent == EmptyPathComponent {
    init(parameters: Parameters) {
        self.init(
            parameters: parameters,
            pathComponent: .init()
        )
    }
}

private extension Encodable {
    var dictionary: [String: CustomStringConvertible?] {
        (
            try? JSONSerialization.jsonObject(
                with: JSONEncoder().encode(self)
            )
        ) as? [String: CustomStringConvertible?] ?? [:]
    }
}
