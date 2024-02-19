import Combine
import Foundation

struct UserDefaultsClient {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func fetch<Value>(
        for keyPath: KeyPath<UserDefaults, Value>
    ) -> AnyPublisher<Value, Never> {
        userDefaults.publisher(for: keyPath)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }

    func save<Value>(
        value: Value,
        for keyPath: ReferenceWritableKeyPath<UserDefaults, Value>
    ) {
        userDefaults[keyPath: keyPath] = value
    }
}
