import Foundation

struct ProductTranslator {
    func translate(rakutenEntity: RakutenProductSearchEntity) -> [ProductModel] {
        rakutenEntity.items.map {
            .init(
                name: $0.itemName + " " + $0.catchcopy,
                description: $0.itemCaption,
                price: $0.itemPrice,
                imageUrl: $0.mediumImageUrls.compactMap {
                    .init(string: $0)
                }.first
            )
        }
    }

    func translate(yahooEntity: YahooProductSearchEntity) -> [ProductModel] {
        yahooEntity.hits.map {
            .init(
                name: $0.name,
                description: $0.description,
                price: $0.price,
                imageUrl: .init(string: $0.image.medium)
            )
        }
    }
}
