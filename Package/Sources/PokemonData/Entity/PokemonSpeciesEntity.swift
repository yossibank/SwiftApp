import API
import CodingKeys
import StructBuilder

@Buildable
@CodingKeys(.all)
public struct PokemonSpeciesEntity: DataStructure {
    public let id: Int
    public let isLegendary: Bool
    public let names: [PokemonNameEntity]
}

@Buildable
@CodingKeys(.all)
public struct PokemonNameEntity: DataStructure {
    public let language: PokemonLanguageEntity
    public let name: String
}

@Buildable
@CodingKeys(.all)
public struct PokemonLanguageEntity: DataStructure {
    public let name: String
    public let url: String
}

#if DEBUG
    public extension PokemonSpeciesEntity {
        static func mock(id: Int) -> PokemonSpeciesEntity {
            PokemonSpeciesEntityBuilder(
                id: id,
                isLegendary: false,
                names: [
                    PokemonNameEntityBuilder(
                        language: PokemonLanguageEntityBuilder(
                            name: "ja",
                            url: "https://pokeapi.co/api/v2/language/11/"
                        ).build(),
                        name: "フシギダネ\(id.description)"
                    ).build()
                ]
            ).build()
        }
    }
#endif
