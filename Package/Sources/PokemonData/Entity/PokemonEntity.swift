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

#if DEBUG
    public extension PokemonEntity {
        static func mock(id: Int) -> PokemonEntity {
            PokemonEntityBuilder(
                id: id,
                name: "フシギダネ\(id.description)",
                isDefault: true,
                sprites: PokemonSpritesEntityBuilder(
                    backDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/1.png",
                    backFemale: nil,
                    backShiny: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/shiny/1.png",
                    backShinyFemale: nil,
                    frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png",
                    frontFemale: nil,
                    frontShiny: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/1.png",
                    frontShinyFemale: nil,
                    other: PokemonOtherEntityBuilder(
                        dreamWorld: PokemonDreamWorldEntityBuilder(
                            frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/dream-world/1.svg",
                            frontFemale: nil
                        ).build(),
                        home: PokemonHomeEntityBuilder(
                            frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/1.png",
                            frontFemale: nil,
                            frontShiny: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/shiny/1.png",
                            frontShinyFemale: nil
                        ).build(),
                        officialArtwork: PokemonOfficialArtworkEntityBuilder(
                            frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png",
                            frontShiny: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/shiny/1.png"
                        ).build()
                    ).build()
                ).build()
            ).build()
        }
    }
#endif
