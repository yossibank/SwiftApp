import Foundation

// https://developer.yahoo.co.jp/webapi/shopping/shopping/v3/itemsearch.html
struct YahooProductSearchEntity: DataStructure {
    /// [総検索ヒット件数]
    let totalResultsAvailable: Int
    /// [返却された商品件数]
    let totalResultsReturned: Int
    /// [最初のデータが何件目にあたるか] 最初=1
    let firstResultsPosition: Int
    /// [検索情報]
    let request: YahooRequest
    /// [検索結果]
    let hits: [YahooItem]

    struct YahooItem: DataStructure {
        /// [検索結果の順番]
        let index: Int
        /// [商品名]
        let name: String
        /// [商品説明]
        let description: String
        /// [キャッチコピー]
        let headLine: String
        /// [在庫情報] true:在庫ありのみ false:在庫なしのみ
        let inStock: Bool
        /// [商品URL]
        let url: String
        /// [画像ID]
        let imageId: String
        /// [商品画像]
        let image: YahooImage
        /// [商品コード] seller_managed_item_id
        let code: String
        /// [JANコード]
        let janCode: String
        /// [支払いコード]
        let payment: String
        /// [発売日]
        let releaseDate: Int?
        /// [商品状態] new:新品 used:中古
        let condition: String
        /// [アフィリエイト料率] 0.1刻み
        let affiliateRate: Int
        /// [価格]
        let price: Int
        /// [プレミアム会員価格]
        let premiumPrice: Int
        /// [プレミアム割引種別] normal・original・sale
        let premiumDiscountType: String?
        /// [プレミアム割引率]
        let premiumDiscountRate: Int?
        /// [レビュー]
        let review: YahooReview
        /// [価格情報]
        let priceLabel: YahooPriceLabel
        /// [ポイント情報]
        let point: YahooPoint
        /// [送料情報]
        let shipping: YahooShipping
        /// [ジャンルカテゴリー情報]
        let genreCategory: YahooGenreCategory
        /// [親ジャンルカテゴリー情報]
        let parentGenreCategories: [YahooGenreCategory]
        /// [ブランド情報]
        let brand: YahooBrand
        /// [親ブランド情報]
        let parentBrands: [YahooBrand]
        /// [販売者情報]
        let seller: YahooSeller
        /// [配送情報]
        let delivery: YahooDelivery
    }

    struct YahooRequest: DataStructure {
        /// [検索クエリ]
        let query: String
    }

    struct YahooImage: DataStructure {
        /// [小画像] 76×76サイズの画像URL
        let small: String
        /// [中画像] 146×146サイズの画像URL
        let medium: String
    }

    struct YahooReview: DataStructure {
        /// [レビュー平均]
        let rate: Float
        /// [レビュー件数]
        let count: Int
        /// [レビューページURL]
        let url: String
    }

    struct YahooPriceLabel: DataStructure {
        /// [税込み価格かどうか]
        let taxable: Bool?
        /// [通常価格]
        let defaultPrice: Int
        /// [セール価格]
        let discountedPrice: Int?
        /// [定価] メーカー小売希望価格
        let fixedPirce: Int?
        /// [プレミアム会員価格]
        let premiumPrice: Int?
        /// [セール期間開始日時] タイムスタンプ
        let periodStart: Int?
        /// [セール期間終了日時] タイムスタンプ
        let periodEnd: Int?
    }

    struct YahooPoint: DataStructure {
        /// [基本ポイント数] Tポイント
        let amount: Int
        /// [基本ポイント倍率] Tポイント
        let times: Int
    }

    struct YahooShipping: DataStructure {
        /// [送料条件コード] 1:設定無し 2:送料無料 3:条件付き送料無料
        let code: Int
        /// [名前] コードに紐づく名前
        let name: String
    }

    struct YahooGenreCategory: DataStructure {
        /// [ジャンルカテゴリID]
        let id: Int
        /// [ジャンルカテゴリ名]
        let name: String
        /// [ジャンルカテゴリの階層]
        let depth: Int
    }

    struct YahooBrand: DataStructure {
        /// [ブランドID]
        let id: Int
        /// [ブランド名]
        let name: String
    }

    struct YahooSeller: DataStructure {
        /// [ストアID]
        let sellerId: String
        /// [ストア名]
        let name: String
        /// [ストアURL]
        let url: String
        /// [ベストストアかどうか]
        let isBestSeller: Bool
        let review: Review
        let imageId: String

        struct Review: DataStructure {
            /// [ストアレビュー平均]
            let rate: Float
            /// [ストアレビュー件数]
            let count: Int
        }
    }

    struct YahooDelivery: DataStructure {
        /// [都道府県コード] 01~47
        let area: String
        /// [注文締め時間] 1~24
        let deadLine: Int?
        /// [配送にかかる日数] 0:きょうつく 1:あすつく
        let day: Int?
    }
}
