import AppDomain
import Foundation
import PokemonDomain
import Utility

@MainActor
public final class PokemonViewModel: ObservableObject {
    @Published private(set) var models: [PokemonModel] = []
    @Published private(set) var appError: AppError?

    private let useCase: PokemonUseCaseProtocol

    public init(useCase: PokemonUseCaseProtocol) {
        self.useCase = useCase
    }
}

public extension PokemonViewModel {
    func fetch() async {
        do {
            models = try await (1 ... 151).asyncMap {
                try await useCase.fetchPokemon(id: $0)
            }
        } catch {
            appError = AppError.parse(error)
        }
    }
}
