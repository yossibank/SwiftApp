import Foundation

enum APIError: Error {
    case badURL
    case badRequest
    case badDecode
    case unknown
}
