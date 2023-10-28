public enum CodingKeysOption {
    case all
    case select([String])
    case exclude([String])
    case custom([String: String])

    var necessaryProperties: [String] {
        switch self {
        case .all: []
        case let .select(array), let .exclude(array): array
        case let .custom(dictionary): .init(dictionary.keys)
        }
    }

    static func associatedValueArray(
        _ caseName: String,
        associatedValue: [String]
    ) -> Self? {
        switch caseName {
        case "select": .select(associatedValue)
        case "exclude": .exclude(associatedValue)
        default: nil
        }
    }

    static func associatedValueDictionary(
        _ caseName: String,
        associatedValue: [String: String]
    ) -> Self? {
        caseName == "custom"
            ? .custom(associatedValue)
            : nil
    }
}
