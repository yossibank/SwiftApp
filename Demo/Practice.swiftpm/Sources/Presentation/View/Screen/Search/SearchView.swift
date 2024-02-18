import SwiftUI

struct SearchView: View {
    @StateObject var viewModel: SearchViewModel

    init(viewModel: SearchViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 32) {
            HStack(spacing: 16) {
                Text("検索サイト")
                    .font(.system(size: 14, weight: .bold))

                HStack(spacing: 12) {
                    Button {
                        viewModel.select(engine: .yahoo)
                    } label: {
                        Label(
                            title: {
                                Text("Yahoo")
                                    .font(.system(size: 14))
                            },
                            icon: {
                                Image("yahoo", bundle: .module)
                                    .resizable()
                                    .frame(width: 14, height: 14)
                            }
                        )
                    }
                    .buttonStyle(
                        BorderedRoundedButtonStyle(
                            isSelected: viewModel.state.searchEngines.contains(.yahoo)
                        )
                    )

                    Button {
                        viewModel.select(engine: .rakuten)
                    } label: {
                        Label(
                            title: {
                                Text("Rakuten")
                                    .font(.system(size: 14))
                            },
                            icon: {
                                Image("rakuten", bundle: .module)
                                    .resizable()
                                    .frame(width: 14, height: 14)
                            }
                        )
                    }
                    .buttonStyle(
                        BorderedRoundedButtonStyle(
                            isSelected: viewModel.state.searchEngines.contains(.rakuten)
                        )
                    )
                }
            }
            .padding(.vertical, 8)

            switch viewModel.state.viewState {
            case .initial:
                InitialView()

            case let .loading(items):
                if items.isEmpty {
                    CenterView {
                        LoadingView()
                    }
                } else {
                    VStack {
                        SearchItemView(items: items)

                        LoadingView()
                    }
                }

            case let .initialError(appError):
                CenterView {
                    ErrorView(
                        errorDescription: appError.errorDescription,
                        didTapReloadButton: {
                            Task { @MainActor in
                                await viewModel.search()
                            }
                        }
                    )
                }

            case let .loadingError(appError):
                Text("エラー")

            case .empty:
                CenterView {
                    NoResultView(title: "検索した商品が見つかりませんでした")
                }

            case let .loaded(items):
                VStack(spacing: 16) {
                    if viewModel.state.isEmptySearchEngine {
                        FilteringEmptyView()
                    } else {
                        SearchItemView(items: items)
                    }
                }
            }

            Spacer()
        }
        .searchable(
            text: .init(
                get: {
                    viewModel.state.keyword
                },
                set: { text in
                    viewModel.state.keyword = text
                }
            ),
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "商品検索"
        )
        .onSubmit(of: .search) {
            Task { @MainActor in
                await viewModel.search()
            }
        }
    }

    private struct FilteringEmptyView: View {
        var body: some View {
            Text("検索サイトが一つも選択されていません")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.red)
        }
    }

    private struct SearchItemView: View {
        let items: [ProductModel]

        var body: some View {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(items, id: \.self) { item in
                        Text(item.name)
                        Text(String(describing: item.price))
                        AsyncImage(url: item.imageUrl)
                            .frame(width: 128, height: 128)
                        Divider()
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

#Preview {
    SearchView(
        viewModel: SearchViewModel(
            state: .init(viewState: .empty),
            dependency: .init(
                apiClient: .init(),
                translator: .init()
            )
        )
    )
}
