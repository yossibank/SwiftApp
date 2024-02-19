import Foundation

extension UserDefaults {
    var test1: String {
        get { object(key: .test1, default: "") }
        set { set(key: .test1, value: newValue) }
    }

    var test2: Int {
        get { object(key: .test2, default: 0) }
        set { set(key: .test2, value: newValue) }
    }

    var test3: Bool {
        get { object(key: .test3, default: false) }
        set { set(key: .test3, value: newValue) }
    }
}

extension UserDefaults {
    func object<Value>(
        key: UserDefaultsKey,
        default defaultValue: Value
    ) -> Value {
        object(forKey: key.rawValue) as? Value ?? defaultValue
    }

    func set(
        key: UserDefaultsKey,
        value: some Any
    ) {
        set(value, forKey: key.rawValue)
    }
}
