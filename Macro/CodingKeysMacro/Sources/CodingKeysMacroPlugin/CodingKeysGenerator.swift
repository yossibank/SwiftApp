import SwiftSyntax
import SwiftSyntaxBuilder

struct CodingKeysGenerator {
    enum CodingKeysStrategy {
        case equal(String, String)
        case skip(String)

        var enumCaseElementSyntax: EnumCaseElementSyntax {
            switch self {
            case let .equal(caseName, value):
                EnumCaseElementSyntax(
                    name: .identifier(caseName),
                    rawValue: InitializerClauseSyntax(
                        equal: .equalToken(),
                        value: StringLiteralExprSyntax(content: value)
                    )
                )

            case let .skip(caseName):
                EnumCaseElementSyntax(name: .identifier(caseName))
            }
        }
    }

    let option: CodingKeysOption
    let properties: [String]

    private var strategies: [CodingKeysStrategy] {
        properties
            .map {
                switch option {
                case .all:
                    return .equal($0, $0.snakecased())

                case let .select(selectedProperties):
                    if selectedProperties.contains($0) {
                        return .equal($0, $0.snakecased())
                    } else {
                        return .skip($0)
                    }

                case let .exclude(excludedProperties):
                    if excludedProperties.contains($0) {
                        return .skip($0)
                    } else {
                        return .equal($0, $0.snakecased())
                    }

                case let .custom(customNamePair):
                    if customNamePair.map(\.key).contains($0),
                       let value = customNamePair[$0] {
                        return .equal($0, value)
                    } else {
                        return .equal($0, $0.snakecased())
                    }
                }
            }
            .map { (strategy: CodingKeysStrategy) in
                switch strategy {
                case let .equal(key, value):
                    if key == value {
                        return .skip(key)
                    }

                default:
                    break
                }

                return strategy
            }
    }

    init(
        option: CodingKeysOption,
        properties: [String]
    ) {
        self.option = option
        self.properties = properties
    }

    func generate() -> EnumDeclSyntax {
        EnumDeclSyntax(
            name: .identifier("CodingKeys"),
            inheritanceClause: InheritanceClauseSyntax {
                InheritedTypeSyntax(type: TypeSyntax(stringLiteral: "String"))
                InheritedTypeSyntax(type: TypeSyntax(stringLiteral: "CodingKey"))
            }
        ) {
            MemberBlockItemListSyntax(
                strategies.map { stragegy in
                    MemberBlockItemSyntax(
                        decl: EnumCaseDeclSyntax(
                            elements: EnumCaseElementListSyntax(
                                arrayLiteral: stragegy.enumCaseElementSyntax
                            )
                        )
                    )
                }
            )
        }
    }
}
