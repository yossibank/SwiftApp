import API
import AppDomain
import PokemonData

/// @mockable
public protocol PokemonSpeciesUseCaseProtocol {
    func fetchPokemonSpecies(id: Int) async throws -> PokemonSpeciesModel
}

public struct PokemonSpeciesUseCase: PokemonSpeciesUseCaseProtocol {
    private let repository: PokemonRepositoryProtocol
    private let translator: PokemonSpeciesTranslatorProtocol

    init(
        repository: PokemonRepositoryProtocol,
        translator: PokemonSpeciesTranslatorProtocol
    ) {
        self.repository = repository
        self.translator = translator
    }

    public func fetchPokemonSpecies(id: Int) async throws -> PokemonSpeciesModel {
        do {
            let entity = try await repository.fetchSpeciesPokemon(id: id)
            let model = translator.translate(entity)
            return model
        } catch {
            throw APIError.parse(error)
        }
    }
}
