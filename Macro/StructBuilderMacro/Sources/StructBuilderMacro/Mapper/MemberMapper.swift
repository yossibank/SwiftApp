import SwiftSyntax

typealias Member = (identifier: TokenSyntax, type: TypeSyntax)

struct MemberMapper {
    // 構造体の全てのプロパティ名、型名抽出(例での`name`プロパティ名, `String`型)
    static func mapFrom(members: MemberBlockItemListSyntax) throws -> [Member] {
        try members.map {
            (identifier: try getIdentifierMember($0), type: try getTypeFromMember($0))
        }
    }

    // MemberBlockItemSyntaxからIdentifierPatternSyntaxのidentifierを取り出す(nameなどのプロパティ名)
    private static func getIdentifierMember(_ member: MemberBlockItemSyntax) throws -> TokenSyntax {
        guard let identifier = member.decl.as(VariableDeclSyntax.self)?.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier else {
            throw "Missing identifier on member"
        }

        return identifier
    }

    // MemberBlockItemSyntaxからTypeAnnotationSyntaxのtype(型)を取り出す(Stringなどの型)
    private static func getTypeFromMember(_ member: MemberBlockItemSyntax) throws -> TypeSyntax {
        guard let type = member.decl.as(VariableDeclSyntax.self)?.bindings.first?.typeAnnotation?.as(TypeAnnotationSyntax.self)?.type else {
            throw "Missing type on member"
        }

        return type
    }
}
