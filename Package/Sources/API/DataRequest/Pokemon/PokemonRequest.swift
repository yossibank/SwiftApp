import Foundation

public struct PokemonRequest: Request {
    public typealias Parameters = EmptyParameters
    public typealias Response = PokemonDataObject

    public var baseURL: String { "https://pokeapi.co/api/v2" }
    public var path: String { "/pokemon/\(id.description)" }
    public var method: HTTPMethod { .get }

    public let parameters: Parameters

    private let id: Int

    public init(
        parameters: Parameters,
        pathComponent id: Int
    ) {
        self.parameters = parameters
        self.id = id
    }
}
