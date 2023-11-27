import PokemonDomain
import SwiftUI

public struct PokemonView: View {
    @StateObject var viewModel: PokemonViewModel

    public init(viewModel: PokemonViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }

    public var body: some View {
        ScrollView {
            switch viewModel.state {
            case .initial:
                EmptyView()

            case .loading:
                EmptyView()

            case let .error(appError):
                EmptyView()

            case .empty:
                EmptyView()

            case let .loaded(viewData):
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(viewData, id: \.id) { data in
                            HStack(spacing: 32) {
                                VStack(spacing: 12) {
                                    Text("図鑑番号: No\(data.id.description)")
                                    Text(data.name)
                                }

                                AsyncImage(url: data.imageURL) { image in
                                    image.resizable()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 100, height: 100)
                            }

                            Divider()
                        }
                    }
                    .padding(.leading, 48)
                }
            }
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
