import API

/// @mockable
public protocol PokemonDataStoreProtocol {
    func fetchPokemon(id: Int) async throws -> PokemonEntity
    func fetchSpeciesPokemon(id: Int) async throws -> PokemonSpeciesEntity
}

public struct PokemonDataStore: PokemonDataStoreProtocol {
    private let apiClient: APIClientProtocol

    public init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    public func fetchPokemon(id: Int) async throws -> PokemonEntity {
        do {
            let entity = try await apiClient.request(item: PokemonRequest(pathComponent: id))
            return entity
        } catch {
            throw APIError.parse(error)
        }
    }

    public func fetchSpeciesPokemon(id: Int) async throws -> PokemonSpeciesEntity {
        do {
            let entity = try await apiClient.request(item: PokemonSpeciesRequest(pathComponent: id))
            return entity
        } catch {
            throw APIError.parse(error)
        }
    }
}

public enum PokemonDataStoreFactory {
    static func provide() -> PokemonDataStoreProtocol {
        PokemonDataStore(apiClient: APIClient())
    }
}
