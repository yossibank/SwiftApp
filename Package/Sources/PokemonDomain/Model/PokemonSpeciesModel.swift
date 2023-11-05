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
