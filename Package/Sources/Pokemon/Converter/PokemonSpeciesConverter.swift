import API
import Foundation

/// @mockable
public protocol PokemonSpeciesConverterInput {
    func convert(_ pokemon: PokemonSpeciesDataObject) -> PokemonSpeciesModelObject
}

public struct PokemonSpeciesConverter: PokemonSpeciesConverterInput {
    public func convert(_ pokemon: PokemonSpeciesDataObject) -> PokemonSpeciesModelObject {
        .init(
            id: pokemon.id,
            isLegendary: pokemon.isLegendary,
            japaneseName: pokemon.names.filter { $0.language.name == "ja" }.first?.name ?? "",
            names: convert(names: pokemon.names)
        )
    }
}

private extension PokemonSpeciesConverter {
    func convert(names: [PokemonDataName]) -> [PokemonModelName] {
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
