import Foundation
import StructBuilder

@Buildable
public struct PokemonModel: Hashable {
    public let id: Int
    public let name: String
    public let imageURL: URL?
    public let sprites: PokemonSpritesModel
}

@Buildable
public struct PokemonSpritesModel: Hashable {
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
public struct PokemonOtherModel: Hashable {
    public let dreamWorld: PokemonDreamWorldModel
    public let home: PokemonHomeModel
    public let officialArtwork: PokemonOfficialArtworkModel
}

@Buildable
public struct PokemonDreamWorldModel: Hashable {
    public let frontDefaultURL: URL?
    public let frontFemaleURL: URL?
}

@Buildable
public struct PokemonHomeModel: Hashable {
    public let frontDefaultURL: URL?
    public let frontFemaleURL: URL?
    public let frontShinyURL: URL?
    public let frontShinyFemaleURL: URL?
}

@Buildable
public struct PokemonOfficialArtworkModel: Hashable {
    public let frontDefaultURL: URL?
    public let frontShinyURL: URL?
}

#if DEBUG
    public extension PokemonModel {
        static func mock(id: Int) -> PokemonModel {
            PokemonModelBuilder(
                id: id,
                name: "フシギダネ\(id.description)",
                imageURL: .init(
                    string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png"
                ),
                sprites: PokemonSpritesModelBuilder(
                    backDefaultURL: .init(
                        string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/1.png"
                    ),
                    backFemaleURL: nil,
                    backShinyURL: .init(
                        string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/shiny/1.png"
                    ),
                    backShinyFemaleURL: nil,
                    frontDefaultURL: .init(
                        string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png"
                    ),
                    frontFemaleURL: nil,
                    frontShinyURL: .init(
                        string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/1.png"
                    ),
                    frontShinyFemaleURL: nil,
                    other: PokemonOtherModelBuilder(
                        dreamWorld: PokemonDreamWorldModelBuilder(
                            frontDefaultURL: .init(
                                string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/dream-world/1.svg"
                            ),
                            frontFemaleURL: nil
                        ).build(),
                        home: PokemonHomeModelBuilder(
                            frontDefaultURL: .init(
                                string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/1.png"
                            ),
                            frontFemaleURL: nil,
                            frontShinyURL: .init(
                                string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/shiny/1.png"
                            ),
                            frontShinyFemaleURL: nil
                        ).build(),
                        officialArtwork: PokemonOfficialArtworkModelBuilder(
                            frontDefaultURL: .init(
                                string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png"
                            ),
                            frontShinyURL: .init(
                                string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/shiny/1.png"
                            )
                        ).build()
                    ).build()
                ).build()
            ).build()
        }
    }
#endif
