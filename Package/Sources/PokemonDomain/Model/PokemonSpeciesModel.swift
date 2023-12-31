import Foundation
import StructBuilder

@Buildable
public struct PokemonSpeciesModel: Equatable {
    public let id: Int
    public let isLegendary: Bool
    public let japaneseName: String
    public let names: [PokemonNameModel]
}

@Buildable
public struct PokemonNameModel: Equatable {
    public let language: PokemonLanguageModel
    public let name: String
}

@Buildable
public struct PokemonLanguageModel: Equatable {
    public let name: String
    public let url: URL?
}

#if DEBUG
    public extension PokemonSpeciesModel {
        static func mock(id: Int) -> PokemonSpeciesModel {
            PokemonSpeciesModelBuilder(
                id: id,
                isLegendary: false,
                japaneseName: "フシギダネ\(id.description)",
                names: [
                    PokemonNameModelBuilder(
                        language: PokemonLanguageModelBuilder(
                            name: "ja",
                            url: .init(string: "https://pokeapi.co/api/v2/language/11/")
                        ).build(),
                        name: "フシギダネ\(id.description)"
                    ).build()
                ]
            ).build()
        }
    }
#endif
