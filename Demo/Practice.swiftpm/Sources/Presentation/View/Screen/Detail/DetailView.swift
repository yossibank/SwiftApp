import SwiftUI

struct DetailView: View {
    let item: ProductModel

    var body: some View {
        GeometryReader { geometry in
            VStack {
                AsyncImageView(
                    url: item.imageURL,
                    successImage: { image in
                        image.resizable()
                    },
                    failureImage: {
                        Image("noImage", bundle: .module).resizable()
                    },
                    placeholderImage: {
                        Image("placeholder", bundle: .module).resizable()
                    }
                )
                .frame(
                    width: geometry.size.width * 0.5,
                    height: geometry.size.width * 0.5,
                    alignment: .center
                )
            }
        }
    }
}

#Preview {
    DetailView(
        item: .init(
            id: "id",
            name: "name",
            description: "description",
            price: "10000",
            imageURL: .init(
                string: "https://placehold.jp/3d4070/ffffff/150x150.png"
            ),
            imageURLs: [
                .init(
                    string: "https://placehold.jp/3d4070/ffffff/150x150.png"
                )!,
                .init(
                    string: "https://placehold.jp/1e5c50/ffffff/150x150.png"
                )!
            ],
            itemURL: .init(string: "https://yahoo.co.jp"),
            searchEngine: .rakuten
        )
    )
}
