@testable import AppDomain
@testable import PokemonData

/// @mockable
public protocol PokemonUseCaseProtocol {
    func fetchPokemon(id: Int) async throws -> PokemonModel
}

public struct PokemonUseCase: PokemonUseCaseProtocol {
    private let repository: PokemonRepositoryProtocol
    private let translator: PokemonTranslatorProtocol

    public init(
        repository: PokemonRepositoryProtocol,
        translator: PokemonTranslatorProtocol
    ) {
        self.repository = repository
        self.translator = translator
    }

    public func fetchPokemon(id: Int) async throws -> PokemonModel {
        do {
            let entity = try await repository.fetchPokemon(id: id)
            let model = translator.translate(entity)
            return model
        } catch {
            throw AppError.parse(error)
        }
    }
}

#if DEBUG
    public extension PokemonUseCaseProtocol {
        func fetchPokemon(id: Int) async throws -> PokemonModel {
            PokemonModel.mock(id: id)
        }
    }

    public struct PokemonUseCaseMock: PokemonUseCaseProtocol {
        public init() {}
    }
#endif
