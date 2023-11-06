import PokemonDomain
import SwiftUI

public struct PokemonView: View {
    @StateObject var viewModel: PokemonViewModel

    public init(viewModel: PokemonViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }

    public var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 32) {
                ForEach(viewModel.models, id: \.id) { model in
                    HStack(spacing: 32) {
                        VStack(spacing: 12) {
                            Text("図鑑番号: No\(model.id.description)")
                            Text(model.name)
                        }

                        AsyncImage(url: model.imageURL) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 100, height: 100)
                    }
                }
            }
            .padding(.leading, 48)
        }
        .onAppear {
            Task {
                await viewModel.fetch()
            }
        }
    }
}

#Preview {
    PokemonView(viewModel: .init(useCase: PokemonUseCaseMock()))
}
