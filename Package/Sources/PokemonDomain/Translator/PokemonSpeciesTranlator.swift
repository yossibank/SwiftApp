import Foundation
import PokemonData

/// @mockable
public protocol PokemonSpeciesTranlatorProtocol {
    func translate(_ entity: PokemonSpeciesEntity) -> PokemonSpeciesModel
}

public struct PokemonSpeciesTranlator: PokemonSpeciesTranlatorProtocol {
    public func translate(_ entity: PokemonSpeciesEntity) -> PokemonSpeciesModel {
        .init(
            id: entity.id,
            isLegendary: entity.isLegendary,
            japaneseName: entity.names.filter { $0.language.name == "ja" }.first?.name ?? "",
            names: translate(names: entity.names)
        )
    }
}

private extension PokemonSpeciesTranlator {
    func translate(names: [PokemonNameEntity]) -> [PokemonNameModel] {
        names.map {
            .init(
                language: .init(
                    name: $0.language.name,
                    url: .init(string: $0.language.url)
                ),
                name: $0.name
            )
        }
    }
}
