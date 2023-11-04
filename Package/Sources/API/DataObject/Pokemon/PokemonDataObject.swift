import CodingKeys
import StructBuilder

@Buildable
@CodingKeys(.all)
public struct PokemonDataObject: DataStructure {
    public let id: Int
    public let name: String
    public let isDefault: Bool
    public let sprites: PokemonDataSprites
}

@Buildable
@CodingKeys(.all)
public struct PokemonDataSprites: DataStructure {
    public let backDefault: String?
    public let backFemale: String?
    public let backShiny: String?
    public let backShinyFemale: String?
    public let frontDefault: String?
    public let frontFemale: String?
    public let frontShiny: String?
    public let frontShinyFemale: String?
    public let other: PokemonDataOther
}

@Buildable
@CodingKeys(.custom(["officialArtwork": "official-artwork"]))
public struct PokemonDataOther: DataStructure {
    public let dreamWorld: PokemonDataDreamWorld
    public let home: PokemonDataHome
    public let officialArtwork: PokemonDataOfficialArtwork
}

@Buildable
@CodingKeys(.all)
public struct PokemonDataDreamWorld: DataStructure {
    public let frontDefault: String?
    public let frontFemale: String?
}

@Buildable
@CodingKeys(.all)
public struct PokemonDataHome: DataStructure {
    public let frontDefault: String?
    public let frontFemale: String?
    public let frontShiny: String?
    public let frontShinyFemale: String?
}

@Buildable
@CodingKeys(.all)
public struct PokemonDataOfficialArtwork: DataStructure {
    public let frontDefault: String?
    public let frontShiny: String?
}
