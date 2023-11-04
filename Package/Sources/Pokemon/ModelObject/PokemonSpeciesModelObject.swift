import Foundation
import StructBuilder

@Buildable
public struct PokemonSpeciesModelObject: Equatable {
    public let id: Int
    public let isLegendary: Bool
    public let japaneseName: String?
    public let names: [PokemonModelName]
}

@Buildable
public struct PokemonModelName: Equatable {
    public let language: PokemonModelLanguage
    public let name: String
}

@Buildable
public struct PokemonModelLanguage: Equatable {
    public let name: String
    public let url: URL?
}
