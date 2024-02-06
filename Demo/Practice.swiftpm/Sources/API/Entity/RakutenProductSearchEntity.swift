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
        /// [商品価格ベースフィールド] 以下の文字列のいずれかを含む
        /// 「itemPriceMin1」、「itemPriceMin2」、「itemPriceMin3」
        let itemPriceBaseField: String
        /// [商品価格max1] 全ての商品の中での最高価格
        let itemPriceMax1: Int
        /// [商品価格max2] 検索可能な商品の中での最高価格
        let itemPriceMax2: Int
        /// [商品価格max3] 購入可能な商品の中での最高価格
        let itemPriceMax3: Int
        /// [商品価格min1] 全ての商品の中での最低価格
        let itemPriceMin1: Int
        /// [商品価格min2] 検索可能な商品の中での最低価格
        let itemPriceMin2: Int
        /// [商品価格min3] 購入可能な商品の中での最低価格
        let itemPriceMin3: Int
        /// [商品画像有無フラグ] 0:商品画像無し 1:商品画像有り
        let imageFlag: Int
        /// [商品画像64×64URL] 最大3枚のhttpsではじまる商品画像の配列
        let smallImageUrls: [String]
        /// [商品画像128×128URL] 最大3枚のhttpsではじまる商品画像の配列
        let mediumImageUrls: [String]
        /// [販売可能フラグ] 0:販売不可能 1:販売可能
        let availability: Int
        /// [消費税フラグ] 0:税込 1:税別
        let taxFlag: Int
        /// [送料フラグ] 0:送料込 1:送料別
        let postageFlag: Int
        /// [クレジットカード利用可能フラグ] 0:カード利用不可 1:カード利用可
        let creditCardFlag: Int
        /// [クレジットカード利用可能フラグ] 0:カード利用不可 1:カード利用可
        let shipOverseasFlag: Int
        /// [海外配送対象地域] 「/」区切りで対応国が表示される
        let shipOverseasArea: String
        /// [あす楽フラグ] 0:翌日配送不可 1:翌日配送可能
        let asurakuFlag: Int
        /// [あす楽〆時間] HH:MMで返却される
        let asurakuClosingTime: String
        /// [あす楽配送対象地域] 「/」区切りで対応地域が表示される
        let asurakuArea: String?
        /// [販売開始時刻] タイムセールが設定されている時のみ(YYYY-MM-DD HH:MM形式)
        let startTime: String
        /// [販売終了時刻] タイムセールが設定されている時のみ(YYYY-MM-DD HH:MM形式)
        let endTime: String
        /// [レビュー件数]
        let reviewCount: Int
        /// [レビュー平均]
        let reviewAverage: Double
        /// [商品別ポイント倍付け] 例)5 → 5倍
        let pointRate: Int
        /// [商品別ポイント倍付け開始日時] pointRateの適用開始日時
        let pointRateStartTime: String
        /// [商品別ポイント倍付け終了日時] pointRateの適用終了日時
        let pointRateEndTime: String
        /// [ギフト包装フラグ] 0:ギフト包装不可能 1:ギフト包装可能
        let giftFlag: Int
        /// [店舗名]
        let shopName: String
        /// [店舗コード] 店舗ごとのURL(楽天ドメイン以降のパス)
        let shopCode: String
        /// [店舗URL] httpsから始まる店舗ごとのURL
        let shopUrl: String
        /// [ジャンルID]
        let genreId: String
        /// [タグID] 複数のタグIDを配列で返却される
        let tagIds: [Int]
    }
}
