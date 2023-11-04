import API
import Foundation

/// @mockable
public protocol PokemonConverterInput {
    func convert(_ pokemon: PokemonDataObject) -> PokemonModelObject
}

public struct PokemonConverter: PokemonConverterInput {
    public func convert(_ pokemon: PokemonDataObject) -> PokemonModelObject {
        .init(
            id: pokemon.id,
            name: pokemon.name,
            artworkImageURL: .init(string: pokemon.sprites.other.officialArtwork.frontDefault ?? ""),
            sprites: .init(
                backDefaultURL: .init(string: pokemon.sprites.backDefault ?? ""),
                backFemaleURL: .init(string: pokemon.sprites.backFemale ?? ""),
                backShinyURL: .init(string: pokemon.sprites.backShiny ?? ""),
                backShinyFemaleURL: .init(string: pokemon.sprites.backShinyFemale ?? ""),
                frontDefaultURL: .init(string: pokemon.sprites.frontDefault ?? ""),
                frontFemaleURL: .init(string: pokemon.sprites.frontFemale ?? ""),
                frontShinyURL: .init(string: pokemon.sprites.frontShiny ?? ""),
                frontShinyFemaleURL: .init(string: pokemon.sprites.frontShinyFemale ?? ""),
                other: convert(other: pokemon.sprites.other)
            )
        )
    }
}

private extension PokemonConverter {
    func convert(other: PokemonDataOther) -> PokemonModelOther {
        .init(
            dreamWorld: .init(
                frontDefaultURL: .init(string: other.dreamWorld.frontDefault ?? ""),
                frontFemaleURL: .init(string: other.dreamWorld.frontFemale ?? "")
            ),
            home: .init(
                frontDefaultURL: .init(string: other.home.frontDefault ?? ""),
                frontFemaleURL: .init(string: other.home.frontFemale ?? ""),
                frontShinyURL: .init(string: other.home.frontShiny ?? ""),
                frontShinyFemaleURL: .init(string: other.home.frontShinyFemale ?? "")
            ),
            officialArtwork: .init(
                frontDefaultURL: .init(string: other.officialArtwork.frontDefault ?? ""),
                frontShinyURL: .init(string: other.officialArtwork.frontShiny ?? "")
            )
        )
    }
}
