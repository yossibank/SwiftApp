/// @mockable
public protocol PokemonRepositoryProtocol {
    func fetchPokemon(id: Int) async throws -> PokemonEntity
    func fetchSpeciesPokemon(id: Int) async throws -> PokemonSpeciesEntity
}

public struct PokemonRepository: PokemonRepositoryProtocol {
    private let dataStore: PokemonDataStoreProtocol

    public init(dataStore: PokemonDataStoreProtocol) {
        self.dataStore = dataStore
    }

    public func fetchPokemon(id: Int) async throws -> PokemonEntity {
        try await dataStore.fetchPokemon(id: id)
    }

    public func fetchSpeciesPokemon(id: Int) async throws -> PokemonSpeciesEntity {
        try await dataStore.fetchSpeciesPokemon(id: id)
    }
}
