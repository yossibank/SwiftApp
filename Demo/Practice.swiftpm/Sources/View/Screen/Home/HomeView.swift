import SwiftUI

struct HomeView: View {
    @State private var keyword = ""
    @State private var items: [RakutenProductSearchEntity.RakutenItem] = []

    var body: some View {
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
        .padding(.vertical, 16)
        .searchable(
            text: $keyword,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "商品検索"
        )
        .onSubmit(of: .search) {
            Task { @MainActor in
                let response = try await APIClient().request(
                    item: RakutenProductSearchRequest(parameters: .init(keyword: keyword))
                )

                items = response.items
            }
        }
    }
}

#Preview {
    HomeView()
}
