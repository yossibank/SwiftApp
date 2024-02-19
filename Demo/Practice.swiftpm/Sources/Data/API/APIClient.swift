import AppLogger
import Foundation

struct APIClient {
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

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

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
            urlComponents.path = fullPath.path()
        } else {
            urlComponents.host = fullPath.host
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

        AppLogger.debug(message: urlRequest.curlString)

        return urlRequest
    }
}

private extension URLRequest {
    var curlString: String {
        guard let url else {
            return ""
        }

        var baseCommand = "\ncurl \(url.absoluteString)"

        if httpMethod == "HEAD" {
            baseCommand += " --head"
        }

        var command = [baseCommand]

        if let httpMethod,
           httpMethod != "HEAD" {
            command.append("-X \(httpMethod)")
        }

        if let allHTTPHeaderFields {
            for (key, value) in allHTTPHeaderFields where key != "Cookie" {
                command.append("-H '\(key): \(value)'")
            }
        }

        if let data = httpBody,
           let body = String(data: data, encoding: .utf8) {
            command.append("-d \(body)")
        }

        return command.joined(separator: " \\\n\t")
    }
}
