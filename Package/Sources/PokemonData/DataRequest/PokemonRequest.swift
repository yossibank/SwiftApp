import API

public struct PokemonRequest: Request {
    public typealias Parameters = EmptyParameters
    public typealias Response = PokemonEntity

    public var baseURL: String { "https://pokeapi.co" }
    public var path: String { "/api/v2/pokemon/\(id.description)" }
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
