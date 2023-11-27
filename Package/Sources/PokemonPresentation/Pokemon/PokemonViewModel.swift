import AppDomain
import Foundation
import PokemonDomain
import Utility

@MainActor
public final class PokemonViewModel: ObservableObject {
    @Published private(set) var state: AppState<[PokemonModel]> = .initial
    @Published private(set) var appError: AppError?

    private let useCase: PokemonUseCaseProtocol

    public init(useCase: PokemonUseCaseProtocol) {
        self.useCase = useCase
    }
}

public extension PokemonViewModel {
    func fetch() async {
        state = .loading

        do {
            let models = try await (1 ... 151).concurrentMap { [useCase] in
                try await useCase.fetchPokemon(id: $0)
            }
            state = models.isEmpty ? .empty : .loaded(models)
        } catch {
            state = .error(AppError.parse(error))
        }
    }
}
