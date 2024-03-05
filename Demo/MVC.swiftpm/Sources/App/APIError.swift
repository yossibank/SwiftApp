import Foundation

enum APIError: Error {
    case badURL
    case badRequest
    case decodeError
    case unknown
}
