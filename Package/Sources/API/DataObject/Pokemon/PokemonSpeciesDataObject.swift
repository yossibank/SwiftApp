import CodingKeys
import StructBuilder

@Buildable
@CodingKeys(.all)
public struct PokemonSpeciesDataObject: DataStructure {
    public let id: Int
    public let isLegendary: Bool
    public let names: [PokemonDataName]
}

@Buildable
@CodingKeys(.all)
public struct PokemonDataName: DataStructure {
    public let language: PokemonDataLanguage
    public let name: String
}

@Buildable
@CodingKeys(.all)
public struct PokemonDataLanguage: DataStructure {
    public let name: String
    public let url: String
}
