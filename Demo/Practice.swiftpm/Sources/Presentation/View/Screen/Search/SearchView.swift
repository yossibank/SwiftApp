import SwiftUI

struct SearchView: View {
    @State private var keyword = ""
    @State private var items: [RakutenProductSearchEntity.RakutenItem] = []
    @State private var searchEngines = SearchEngine.allCases
    @State private var isEmptySearchEngine = false

    enum SearchEngine: CaseIterable {
        case yahoo
        case rakuten
    }

    var body: some View {
        VStack(spacing: 16) {
            filteringView

            if isEmptySearchEngine {
                filteringEmptyView
            } else {
                searchItemsView
            }

            Spacer()
        }
        .searchable(
            text: $keyword,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "商品検索"
        )
        .onSubmit(of: .search) {
            isEmptySearchEngine = searchEngines.isEmpty

            guard !isEmptySearchEngine else {
                return
            }

            Task { @MainActor in
                let response = try await APIClient().request(
                    item: RakutenProductSearchRequest(
                        parameters: .init(keyword: keyword)
                    )
                )

                items = response.items
            }
        }
    }

    private var filteringView: some View {
        HStack(spacing: 16) {
            Text("検索サイト")
                .font(.system(size: 14, weight: .bold))

            HStack(spacing: 12) {
                Button {
                    if searchEngines.contains(.yahoo) {
                        searchEngines.removeAll(where: { $0 == .yahoo })
                    } else {
                        searchEngines.append(.yahoo)
                    }
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
                    BorderedRoundedButtonStyle(isSelected: searchEngines.contains(.yahoo))
                )

                Button {
                    if searchEngines.contains(.rakuten) {
                        searchEngines.removeAll(where: { $0 == .rakuten })
                    } else {
                        searchEngines.append(.rakuten)
                    }
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
                    BorderedRoundedButtonStyle(isSelected: searchEngines.contains(.rakuten))
                )
            }
        }
        .padding(.vertical, 8)
    }

    private var filteringEmptyView: some View {
        Text("検索サイトが一つも選択されていません")
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(.red)
    }

    private var searchItemsView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(items, id: \.self) { item in
                    Text(item.itemName)
                    Text(String(describing: item.itemPrice))
                    HStack {
                        ForEach(item.mediumImageUrls.map { URL(string: $0) }, id: \.self) { url in
                            AsyncImage(url: url)
                                .frame(width: 128, height: 128)
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
    SearchView()
}
