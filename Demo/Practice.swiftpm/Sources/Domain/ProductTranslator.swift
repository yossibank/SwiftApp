import Foundation

struct ProductTranslator {
    func translate(_ entity: RakutenProductSearchEntity) -> [ProductModel] {
        entity.items.map {
            .init(
                id: UUID().uuidString,
                name: $0.itemName,
                description: $0.itemCaption,
                price: priceLabel(price: $0.itemPrice),
                imageUrl: $0.mediumImageUrls.compactMap {
                    .init(string: $0)
                }.first,
                searchEngine: .rakuten
            )
        }
    }

    func translate(_ entity: YahooProductSearchEntity) -> [ProductModel] {
        entity.hits.map {
            .init(
                id: UUID().uuidString,
                name: $0.name,
                description: $0.description ?? "",
                price: priceLabel(price: $0.price),
                imageUrl: .init(string: $0.image.medium),
                searchEngine: .yahoo
            )
        }
    }
}

private extension ProductTranslator {
    func priceLabel(price: Int) -> String {
        let format = NumberFormatter()
        format.numberStyle = .decimal
        format.groupingSeparator = ","
        format.groupingSize = 3
        let priceString = format.string(from: NSNumber(integerLiteral: price)) ?? "\(String(describing: price))"
        return priceString + "円"
    }
}
