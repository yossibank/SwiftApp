import Foundation

/// APIにリクエストを送信する際に、ヘッダーに送信する情報をまとめたenum
enum APIRequestHeader: String, CaseIterable {
    case contentType = "Content-Type"

    var value: String {
        switch self {
        case .contentType:
            "application/json"
        }
    }
}
