import CodingKeys
import StructBuilder

@Buildable
@CodingKeys(.all)
public struct PokemonDataObject: DataStructure {
    public let id: Int
    public let name: String
    public let isDefault: Bool
    public let sprites: PokemonSprites
}

@Buildable
@CodingKeys(.all)
public struct PokemonSprites: DataStructure {
    public let backDefault: String?
    public let backFemale: String?
    public let backShiny: String?
    public let backShinyFemale: String?
    public let frontDefault: String?
    public let frontFemale: String?
    public let frontShiny: String?
    public let frontShinyFemale: String?
    public let other: PokemonOther
}

@Buildable
@CodingKeys(.custom(["officialArtwork": "official-artwork"]))
public struct PokemonOther: DataStructure {
    public let dreamWorld: PokemonDreamWorld
    public let home: PokemonHome
    public let officialArtwork: PokemonOfficialArtwork
}

@Buildable
@CodingKeys(.all)
public struct PokemonDreamWorld: DataStructure {
    public let frontDefault: String?
    public let frontFemale: String?
}

@Buildable
@CodingKeys(.all)
public struct PokemonHome: DataStructure {
    public let frontDefault: String?
    public let frontFemale: String?
    public let frontShiny: String?
    public let frontShinyFemale: String?
}

@Buildable
@CodingKeys(.all)
public struct PokemonOfficialArtwork: DataStructure {
    public let frontDefault: String?
    public let frontShiny: String?
}
