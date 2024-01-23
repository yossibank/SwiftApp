import SwiftUI

struct NewsView: View {
    @StateObject private var store = GetNewsEventFetcher()

    var body: some View {
        VStack {
            List(store.articles, id: \.self) { article in
                VStack(alignment: .leading) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(article.title)
                                .font(.headline)
                                .foregroundStyle(.black)
                            Spacer()
                            Text(article.publishedAt)
                                .font(.caption)
                                .foregroundStyle(.gray)
                            Text(article.author ?? "")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                        AsyncImage(
                            url: .init(string: article.urlToImage ?? ""),
                            content: {
                                $0.resizable().frame(width: 100, height: 70)
                            },
                            placeholder: {
                                ProgressView()
                            }
                        )
                    }
                }
            }
        }
        .onAppear {
            Task {
                await store.getNews()
            }
        }
    }
}

#Preview {
    NewsView()
}
