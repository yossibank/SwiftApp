import Foundation
import StructBuilder

@Buildable
public struct PokemonModelObject: Equatable {
    public let id: Int
    public let name: String
    public let artworkImageURL: URL?
    public let sprites: PokemonModelSprites
}

@Buildable
public struct PokemonModelSprites: Equatable {
    public let backDefaultURL: URL?
    public let backFemaleURL: URL?
    public let backShinyURL: URL?
    public let backShinyFemaleURL: URL?
    public let frontDefaultURL: URL?
    public let frontFemaleURL: URL?
    public let frontShinyURL: URL?
    public let frontShinyFemaleURL: URL?
    public let other: PokemonModelOther
}

@Buildable
public struct PokemonModelOther: Equatable {
    public let dreamWorld: PokemonModelDreamWorld
    public let home: PokemonModelHome
    public let officialArtwork: PokemonModelOfficialArtwork
}

@Buildable
public struct PokemonModelDreamWorld: Equatable {
    public let frontDefaultURL: URL?
    public let frontFemaleURL: URL?
}

@Buildable
public struct PokemonModelHome: Equatable {
    public let frontDefaultURL: URL?
    public let frontFemaleURL: URL?
    public let frontShinyURL: URL?
    public let frontShinyFemaleURL: URL?
}

@Buildable
public struct PokemonModelOfficialArtwork: Equatable {
    public let frontDefaultURL: URL?
    public let frontShinyURL: URL?
}
