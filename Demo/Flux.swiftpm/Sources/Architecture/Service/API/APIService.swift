import Combine
import Foundation

protocol APIRequestType {
    associatedtype Response: Decodable

    var path: String { get }
    var queryItems: [URLQueryItem]? { get }
}

protocol APIServiceType {
    func response<Request>(from request: Request) -> AnyPublisher<
        Request.Response,
        APIServiceError
    > where Request: APIRequestType
}

final class APIService: APIServiceType {
    private let baseURL: URL

    init(baseURL: URL = .init(string: "https://api.github.com")!) {
        self.baseURL = baseURL
    }

    func response<Request>(from request: Request) -> AnyPublisher<
        Request.Response,
        APIServiceError
    > where Request: APIRequestType {
        let pathURL = URL(string: request.path, relativeTo: baseURL)!

        var urlComponents = URLComponents(
            url: pathURL,
            resolvingAgainstBaseURL: true
        )!
        urlComponents.queryItems = request.queryItems

        var request = URLRequest(url: urlComponents.url!)
        request.addValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return URLSession.shared.dataTaskPublisher(for: request)
            .map { data, _ in data }
            .mapError { _ in APIServiceError.responseError }
            .decode(type: Request.Response.self, decoder: decoder)
            .mapError(APIServiceError.parseError)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
