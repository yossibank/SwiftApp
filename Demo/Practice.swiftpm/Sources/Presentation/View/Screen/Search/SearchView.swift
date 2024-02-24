import SwiftUI

struct SearchView: View {
    @StateObject var viewModel: SearchViewModel

    init(viewModel: SearchViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 16) {
            SearchEnginesView(viewModel: viewModel)

            ScrollView {
                switch viewModel.state.displayState {
                case .initial:
                    EmptyView()

                case .initialLoading:
                    CenterView {
                        LoadingView()
                    }

                case .emptySearchEngine:
                    CenterView {
                        SearchFilterEmptyView()
                    }

                case .emptySearchItem:
                    CenterView {
                        NoResultView(title: "検索した商品が見つかりませんでした")
                    }

                case let .showError(appError):
                    CenterView {
                        ErrorView(
                            errorDescription: appError.errorDescription,
                            didTapReloadButton: {
                                Task { @MainActor in
                                    await viewModel.search(isAdditionalLoading: false)
                                }
                            }
                        )
                    }

                case let .loaded(items):
                    SearchItemView(
                        viewModel: viewModel,
                        items: items
                    )
                }
            }
            .modifier(
                ToastModifier(
                    isShown: $viewModel.state.isShowToastError,
                    toastType: .error,
                    message: "読み込みに失敗しました"
                )
            )
        }
        .searchable(
            text: .init(
                get: {
                    viewModel.state.searchParameter.keyword
                },
                set: { text in
                    viewModel.state.searchParameter.keyword = text
                }
            ),
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "商品検索"
        )
        .onSubmit(of: .search) {
            Task { @MainActor in
                await viewModel.search(isAdditionalLoading: false)
            }
        }
    }

    private struct SearchFilterEmptyView: View {
        var body: some View {
            Text("検索サイトが一つも選択されていません")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.red)
        }
    }

    private struct SearchEnginesView: View {
        @ObservedObject var viewModel: SearchViewModel

        var body: some View {
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
                            isSelected: viewModel.state.searchParameter.isSelectedYahoo
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
                            isSelected: viewModel.state.searchParameter.isSelectedRakuten
                        )
                    )
                }
            }
            .padding(.vertical, 8)
        }
    }

    private struct SearchItemView: View {
        @ObservedObject var viewModel: SearchViewModel

        let items: [ProductModel]

        var body: some View {
            LazyVStack(spacing: 16) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 12) {
                        AsyncImageView(
                            url: item.imageURL,
                            successImage: { image in
                                image.resizable()
                            },
                            failureImage: {
                                Image("noImage", bundle: .module).resizable()
                            },
                            placeholderImage: {
                                Image("noImage", bundle: .module).resizable()
                            }
                        )
                        .frame(width: 128, height: 128)
                        .clipShape(RoundedRectangle(cornerRadius: 4))

                        VStack(alignment: .leading, spacing: 24) {
                            Text(item.name)
                                .font(.system(size: 16, weight: .bold))
                                .lineLimit(4)

                            HStack {
                                Text(item.price)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.red)

                                Image(item.searchEngine.rawValue, bundle: .module)
                                    .resizable()
                                    .frame(width: 16, height: 16)

                                Spacer()

                                if item.isAddedItem {
                                    Text("追加済み")
                                        .padding(.vertical, 4)
                                        .padding(.horizontal, 8)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(.red)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(.red, lineWidth: 2)
                                        )
                                        .frame(height: 16)
                                } else {
                                    Button {
                                        viewModel.save(item)
                                    } label: {
                                        Text("追加")
                                    }
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.red)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(.red, lineWidth: 2)
                                    )
                                    .frame(height: 16)
                                }
                            }
                        }
                    }
                    .onAppear {
                        Task { @MainActor in
                            await viewModel.additionalLoadingItems(id: item.id)
                        }
                    }

                    Divider()
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    SearchView(
        viewModel: .init(
            state: .init(),
            dependency: .init(
                apiClient: .init(),
                userDefaultsClient: .init(),
                translator: .init()
            )
        )
    )
}
