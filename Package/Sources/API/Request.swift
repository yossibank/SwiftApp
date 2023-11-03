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
    associatedtype Response: Codable
    associatedtype Parameters: Encodable
    associatedtype PathComponent

    // 必須要素
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters { get }

    // オプション要素(デフォルト値あり)
    var body: Data? { get }
    var timeoutInterval: TimeInterval { get }
    var headers: [String: String] { get }
    var queryItems: [URLQueryItem]? { get }

    init(
        parameters: Parameters,
        pathComponent: PathComponent
    )
}

extension Request {
    var body: Data? {
        method == .get
            ? nil
            : try? JSONEncoder().encode(parameters)
    }

    var timeoutInterval: TimeInterval {
        10.0
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

private extension Encodable {
    var dictionary: [String: CustomStringConvertible?] {
        (
            try? JSONSerialization.jsonObject(
                with: JSONEncoder().encode(self)
            )
        ) as? [String: CustomStringConvertible?] ?? [:]
    }
}
