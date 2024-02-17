import Foundation

// https://webservice.rakuten.co.jp/documentation/ichiba-item-search
struct RakutenProductSearchEntity: DataStructure {
    /// [商品情報]
    let items: [RakutenItem]
    /// [検索数]検索結果の総商品数
    let count: Int
    /// [ページ番号]現在のページ番号
    let page: Int
    /// [ページ内商品始追番]検索結果の何件目からか
    let first: Int
    /// [ページ内商品終追番]検索結果の何件目までか
    let last: Int
    /// [ヒット件数番] 1度に返却する商品数
    let hits: Int
    /// [キャリア情報] PC=0 mobile=1 smartphone=2
    let carrier: Int
    /// [総ページ数] 最大100
    let pageCount: Int

    enum CodingKeys: String, CodingKey {
        case items = "Items"
        case count
        case page
        case first
        case last
        case hits
        case carrier
        case pageCount
    }

    struct RakutenItem: DataStructure, Hashable {
        /// [商品名] 従来の商品名は「catchCopy + itemName」で表示される
        let itemName: String
        /// [キャッチコピー] 従来の商品名は「catchCopy + itemName」で表示される
        let catchcopy: String
        /// [商品コード]
        let itemCode: String
        /// [商品価格]
        let itemPrice: Int
        /// [商品説明文]
        let itemCaption: String
        /// [商品URL] httpsではじまる商品のURL
        let itemUrl: String
        /// [商品画像64×64URL] 最大3枚のhttpsではじまる商品画像の配列
        let smallImageUrls: [String]
        /// [商品画像128×128URL] 最大3枚のhttpsではじまる商品画像の配列
        let mediumImageUrls: [String]
    }
}
