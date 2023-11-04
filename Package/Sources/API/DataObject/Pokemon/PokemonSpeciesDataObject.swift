import CodingKeys
import StructBuilder

@Buildable
@CodingKeys(.all)
public struct PokemonSpeciesDataObject: DataStructure {
    public let id: Int
    public let isLegendary: Bool
    public let names: [PokemonName]
}

@Buildable
@CodingKeys(.all)
public struct PokemonName: DataStructure {
    public let language: PokemonLanguage
    public let name: String
}

@Buildable
@CodingKeys(.all)
public struct PokemonLanguage: DataStructure {
    public let name: String
    public let url: String
}
