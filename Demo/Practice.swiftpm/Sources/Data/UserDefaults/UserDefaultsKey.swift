import Foundation

enum UserDefaultsKey: String {
    case test1
    case test2
    case test3
    case itemList
}

struct UserDefaultsKeyValue {
    @UserDefaultsStorage(
        .test1,
        defaultValue: ""
    )
    var test1: String

    @UserDefaultsStorage(
        .test2,
        defaultValue: 0
    )
    var test2: Int
}
