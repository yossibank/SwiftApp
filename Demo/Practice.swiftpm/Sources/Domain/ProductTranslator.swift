import Foundation

struct ProductTranslator {
    func translate(_ entity: RakutenProductSearchEntity) -> [ProductModel] {
        entity.items.map {
            .init(
                name: $0.itemName,
                description: $0.itemCaption,
                price: $0.itemPrice,
                imageUrl: $0.mediumImageUrls.compactMap {
                    .init(string: $0)
                }.first
            )
        }
    }

    func translate(_ entity: YahooProductSearchEntity) -> [ProductModel] {
        entity.hits.map {
            .init(
                name: $0.name,
                description: $0.description ?? "",
                price: $0.price,
                imageUrl: .init(string: $0.image.medium)
            )
        }
    }
}
