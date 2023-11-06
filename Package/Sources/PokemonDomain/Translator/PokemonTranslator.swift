import Foundation
import PokemonData

/// @mockable
public protocol PokemonTranslatorProtocol {
    func translate(_ entity: PokemonEntity) -> PokemonModel
}

public struct PokemonTranslator: PokemonTranslatorProtocol {
    public init() {}

    public func translate(_ entity: PokemonEntity) -> PokemonModel {
        .init(
            id: entity.id,
            name: entity.name,
            imageURL: .init(string: entity.sprites.other.officialArtwork.frontDefault ?? ""),
            sprites: translate(sprites: entity.sprites)
        )
    }
}

private extension PokemonTranslator {
    func translate(sprites: PokemonSpritesEntity) -> PokemonSpritesModel {
        .init(
            backDefaultURL: .init(string: sprites.backDefault ?? ""),
            backFemaleURL: .init(string: sprites.backFemale ?? ""),
            backShinyURL: .init(string: sprites.backShiny ?? ""),
            backShinyFemaleURL: .init(string: sprites.backShinyFemale ?? ""),
            frontDefaultURL: .init(string: sprites.frontDefault ?? ""),
            frontFemaleURL: .init(string: sprites.frontFemale ?? ""),
            frontShinyURL: .init(string: sprites.frontShiny ?? ""),
            frontShinyFemaleURL: .init(string: sprites.frontShinyFemale ?? ""),
            other: .init(
                dreamWorld: .init(
                    frontDefaultURL: .init(string: sprites.other.dreamWorld.frontDefault ?? ""),
                    frontFemaleURL: .init(string: sprites.other.dreamWorld.frontFemale ?? "")
                ),
                home: .init(
                    frontDefaultURL: .init(string: sprites.other.home.frontDefault ?? ""),
                    frontFemaleURL: .init(string: sprites.other.home.frontFemale ?? ""),
                    frontShinyURL: .init(string: sprites.other.home.frontShiny ?? ""),
                    frontShinyFemaleURL: .init(string: sprites.other.home.frontShinyFemale ?? "")
                ),
                officialArtwork: .init(
                    frontDefaultURL: .init(string: sprites.other.officialArtwork.frontDefault ?? ""),
                    frontShinyURL: .init(string: sprites.other.officialArtwork.frontShiny ?? "")
                )
            )
        )
    }
}
