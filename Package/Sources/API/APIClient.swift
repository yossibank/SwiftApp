import Foundation

/// @mockable
protocol APIClientRequest {
    func request<T>(item: some Request<T>) async throws -> T
}

public struct APIClient: APIClientRequest {
    func request<T>(item: some Request<T>) async throws -> T {
        guard let urlRequest = createURLRequest(item) else {
            throw APIError.invalidRequest
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)

            guard let response = response as? HTTPURLResponse else {
                throw APIError.emptyResponse
            }

            guard (200 ... 299).contains(response.statusCode) else {
                throw APIError.invalidStatusCode(response.statusCode)
            }

            return try JSONDecoder().decode(
                T.self,
                from: data
            )
        } catch {
            throw APIError.parse(error)
        }
    }
}

private extension APIClient {
    func createURLRequest(_ requestItem: some Request) -> URLRequest? {
        guard let fullPath = URL(string: requestItem.baseURL + requestItem.path) else {
            return nil
        }

        var urlComponents = URLComponents()
        urlComponents.scheme = fullPath.scheme
        urlComponents.port = fullPath.port
        urlComponents.queryItems = requestItem.queryItems

        if #available(iOS 16.0, *) {
            urlComponents.host = fullPath.host()
        } else {
            urlComponents.host = fullPath.host
        }

        if #available(iOS 16.0, *) {
            urlComponents.path = fullPath.path()
        } else {
            urlComponents.path = fullPath.path
        }

        guard let url = urlComponents.url else {
            return nil
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.timeoutInterval = requestItem.timeoutInterval
        urlRequest.httpMethod = requestItem.method.rawValue
        urlRequest.httpBody = requestItem.body

        requestItem.headers.forEach {
            urlRequest.addValue($1, forHTTPHeaderField: $0)
        }

        print(urlRequest.curlString)

        return urlRequest
    }
}
