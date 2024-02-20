import Foundation

@propertyWrapper
final class UserDefaultsStorage<Value: UserDefaultsCompatible & Equatable> {
    private let publisher: UserDefaults.Publisher<Value>

    init(
        _ key: UserDefaultsKey,
        defaultValue: Value,
        userDefaults: UserDefaultsProtocol = UserDefaults.standard
    ) {
        self.publisher = .init(
            key: key.rawValue,
            default: defaultValue,
            userDefaults: userDefaults
        )
    }

    var wrappedValue: Value {
        get { publisher.value }
        set { publisher.value = newValue }
    }

    var projectedValue: UserDefaults.Publisher<Value> {
        publisher
    }
}
