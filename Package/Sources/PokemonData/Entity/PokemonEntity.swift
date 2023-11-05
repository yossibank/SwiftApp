import API
import CodingKeys
import StructBuilder

@Buildable
@CodingKeys(.all)
public struct PokemonEntity: DataStructure {
    public let id: Int
    public let name: String
    public let isDefault: Bool
    public let sprites: PokemonSpritesEntity
}

@Buildable
@CodingKeys(.all)
public struct PokemonSpritesEntity: DataStructure {
    public let backDefault: String?
    public let backFemale: String?
    public let backShiny: String?
    public let backShinyFemale: String?
    public let frontDefault: String?
    public let frontFemale: String?
    public let frontShiny: String?
    public let frontShinyFemale: String?
    public let other: PokemonOtherEntity
}

@Buildable
@CodingKeys(.custom(["officialArtwork": "official-artwork"]))
public struct PokemonOtherEntity: DataStructure {
    public let dreamWorld: PokemonDreamWorldEntity
    public let home: PokemonHomeEntity
    public let officialArtwork: PokemonOfficialArtworkEntity
}

@Buildable
@CodingKeys(.all)
public struct PokemonDreamWorldEntity: DataStructure {
    public let frontDefault: String?
    public let frontFemale: String?
}

@Buildable
@CodingKeys(.all)
public struct PokemonHomeEntity: DataStructure {
    public let frontDefault: String?
    public let frontFemale: String?
    public let frontShiny: String?
    public let frontShinyFemale: String?
}

@Buildable
@CodingKeys(.all)
public struct PokemonOfficialArtworkEntity: DataStructure {
    public let frontDefault: String?
    public let frontShiny: String?
}
