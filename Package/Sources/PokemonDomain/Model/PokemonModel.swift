import Foundation
import StructBuilder

@Buildable
public struct PokemonModel: Equatable {
    public let id: Int
    public let name: String
    public let imageURL: URL?
    public let sprites: PokemonSpritesModel
}

@Buildable
public struct PokemonSpritesModel: Equatable {
    public let backDefaultURL: URL?
    public let backFemaleURL: URL?
    public let backShinyURL: URL?
    public let backShinyFemaleURL: URL?
    public let frontDefaultURL: URL?
    public let frontFemaleURL: URL?
    public let frontShinyURL: URL?
    public let frontShinyFemaleURL: URL?
    public let other: PokemonOtherModel
}

@Buildable
public struct PokemonOtherModel: Equatable {
    public let dreamWorld: PokemonDreamWorldModel
    public let home: PokemonHomeModel
    public let officialArtwork: PokemonOfficialArtworkModel
}

@Buildable
public struct PokemonDreamWorldModel: Equatable {
    public let frontDefaultURL: URL?
    public let frontFemaleURL: URL?
}

@Buildable
public struct PokemonHomeModel: Equatable {
    public let frontDefaultURL: URL?
    public let frontFemaleURL: URL?
    public let frontShinyURL: URL?
    public let frontShinyFemaleURL: URL?
}

@Buildable
public struct PokemonOfficialArtworkModel: Equatable {
    public let frontDefaultURL: URL?
    public let frontShinyURL: URL?
}
