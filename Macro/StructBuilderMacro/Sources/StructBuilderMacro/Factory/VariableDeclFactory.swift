import SwiftSyntax

struct VariableDeclFactory {
    // MemberBlockItemSyntaxからVariableDeclSyntaxを生成(プロパティ生成、例でのlet name: Stringの部分)
    static func makeMemberVaiable(member: Member) -> VariableDeclSyntax {
        VariableDeclSyntax(
            bindingSpecifier: .keyword(.var),
            bindings: PatternBindingListSyntax {
                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(identifier: member.identifier),
                    typeAnnotation: TypeAnnotationSyntax(type: member.type),
                    initializer: getDefaultInitializerClause(type: member.type)
                )
            }
        )
    }

    // TypeSyntaxからtype(型)の情報をInitializerClauseSyntaxとして取り出す
    private static func getDefaultInitializerClause(type: TypeSyntax) -> InitializerClauseSyntax? {
        guard let defaultExpr = TypeMapper.getDefaultValueFor(type: type) else {
            return nil
        }

        return InitializerClauseSyntax(value: defaultExpr)
    }
}
