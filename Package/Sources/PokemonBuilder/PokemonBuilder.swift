import PokemonData
import PokemonDomain
import PokemonPresentation
import SwiftUI

public struct PokemonBuilder: UIViewControllerRepresentable {
    public init() {}

    public func makeUIViewController(context: Context) -> UIViewController {
        let dataStore = PokemonDataStoreFactory.provide()
        let repository = PokemonRepository(dataStore: dataStore)
        let translator = PokemonTranslator()
        let useCase = PokemonUseCase(repository: repository, translator: translator)
        let viewModel = PokemonViewModel(useCase: useCase)
        let viewController = PokemonViewController(viewModel: viewModel)
        return viewController
    }

    public func updateUIViewController(
        _ uiViewController: UIViewController,
        context: Context
    ) {}
}
