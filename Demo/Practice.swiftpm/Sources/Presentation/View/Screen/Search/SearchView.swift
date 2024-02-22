import SwiftUI

struct SearchView: View {
    @StateObject var viewModel: SearchViewModel

    init(viewModel: SearchViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack(alignment: .top) {
            SearchEnginesView(viewModel: viewModel)
                .frame(height: 60)

            VStack {
                switch viewModel.state.viewState {
                case .initial:
                    CenterView {
                        InitialView()
                    }

                case let .loading(items):
                    if items.isEmpty {
                        CenterView {
                            LoadingView()
                        }
                    } else {
                        VStack {
                            SearchItemView(
                                viewModel: viewModel,
                                items: items,
                                lastItemID: nil
                            )

                            LoadingView()
                        }
                    }

                case let .initialError(appError):
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

                case let .loadingError(appError):
                    Text("エラー")

                case .empty:
                    CenterView {
                        NoResultView(title: "検索した商品が見つかりませんでした")
                    }

                case let .loaded(items):
                    if viewModel.state.isEmptySearchEngine {
                        SearchFilterEmptyView()
                    } else {
                        SearchItemView(
                            viewModel: viewModel,
                            items: items,
                            lastItemID: viewModel.state.lastItemId
                        )
                    }
                }
            }
            .padding(.top, 64)
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
                await viewModel.search(isAdditionalLoading: false)
            }
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
        }
    }

    private struct SearchItemView: View {
        @ObservedObject var viewModel: SearchViewModel

        let items: [ProductModel]
        let lastItemID: String?

        var body: some View {
            ScrollView {
                ScrollViewReader { proxy in
                    LazyVStack(spacing: 16) {
                        ForEach(items, id: \.self) { item in
                            HStack(alignment: .top, spacing: 12) {
                                AsyncImageView(
                                    url: item.imageUrl,
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

                                VStack(alignment: .leading, spacing: 12) {
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
                            .id(item.id)
                            .onAppear {
                                Task { @MainActor in
                                    await viewModel.additionalLoadingItems(id: item.id)
                                }

                                if let lastItemID {
                                    viewModel.resetLastItemID()
                                    proxy.scrollTo(lastItemID, anchor: .bottom)
                                }
                            }

                            Divider()
                        }
                    }
                    .padding(.horizontal, 16)
                }
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
}

#Preview {
    SearchView(
        viewModel: .init(
            state: .init(viewState: .initial),
            dependency: .init(
                apiClient: .init(),
                userDefaultsClient: .init(),
                translator: .init()
            )
        )
    )
}
