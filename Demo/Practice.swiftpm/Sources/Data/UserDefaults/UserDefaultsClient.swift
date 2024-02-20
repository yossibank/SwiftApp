import Foundation

struct UserDefaultsClient {
    private var userDefaultsKeyValue = UserDefaultsKeyValue()

    func value<Value>(
        for keyPath: KeyPath<UserDefaultsKeyValue, Value>
    ) -> Value {
        userDefaultsKeyValue[keyPath: keyPath]
    }

    func setValue<Value>(
        for keyPath: ReferenceWritableKeyPath<UserDefaultsKeyValue, Value>,
        value: Value
    ) {
        userDefaultsKeyValue[keyPath: keyPath] = value
    }
}
