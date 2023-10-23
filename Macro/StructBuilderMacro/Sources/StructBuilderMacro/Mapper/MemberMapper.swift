import SwiftSyntax

typealias Member = (identifier: TokenSyntax, type: TypeSyntax)

struct MemberMapper {
    // 構造体の全てのプロパティ名、型名抽出(例での`name`プロパティ名, `String`型)
    // stored propertyのみ抽出
    static func mapFrom(members: MemberBlockItemListSyntax) throws -> [Member] {
        members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .filter(\.isStoredProperty)
            .filter { !hasStaticModifier($0) }
            .compactMap {
                guard
                    let patternBinding = $0.bindings.first,
                    let identifier = getIdentifierFromMember(patternBinding),
                    let type = getTypeFromMember(patternBinding)
                else {
                    return nil
                }

                return (identifier, type)
            }
    }

    // PatternBindingSyntaxからIdentifierPatternSyntaxのidentifierを取り出す(nameなどのプロパティ名)
    private static func getIdentifierFromMember(_ patternBinding: PatternBindingSyntax) -> TokenSyntax? {
        patternBinding.pattern.as(IdentifierPatternSyntax.self)?.identifier
    }

    // PatternBindingSyntaxからTypeAnnotationSyntaxのtype(型)を取り出す(Stringなどの型)
    private static func getTypeFromMember(_ patternBinding: PatternBindingSyntax) -> TypeSyntax? {
        patternBinding.typeAnnotation?.as(TypeAnnotationSyntax.self)?.type
    }

    // VariableDeclSyntaxからstaticのキーワードのSyntax排除
    private static func hasStaticModifier(_ variable: VariableDeclSyntax) -> Bool {
        variable.modifiers.contains(where: {
            $0.name.text.contains("static")
        })
    }
}

private extension VariableDeclSyntax {
    // stored propertyがどうかを判定する
    var isStoredProperty: Bool {
        guard bindings.count == 1 else {
            return false
        }

        switch bindings.first!.accessorBlock?.accessors {
        case .none:
            return true

        case let .accessors(node):
            for accessor in node {
                switch accessor.accessorSpecifier.tokenKind {
                case .keyword(.willSet), .keyword(.didSet):
                    // Observers can occur on a stored property.
                    break
                default:
                    // Other accessors make it a computed property.
                    return false
                }
            }
            return true

        case .getter:
            return false
        }
    }
}
