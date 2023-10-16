import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct StructBuilderPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        CustomBuilderMacro.self
    ]
}

extension String: Error {}

typealias Member = (identifier: TokenSyntax, type: TypeSyntax)

// https://swift-ast-explorer.com/
//
// 【ベース】
// struct Person {
//     let name: String
// }
//
// 【展開】
// struct PersonBuilder {
//     var name: String = ""
//
//     func build() -> Person {
//         return Person(
//             name: name
//         )
//     }
// }
//
// 【struct上の構造を理解する】
// 構造体全体(0)
// struct(1) Person(2) {(3)(7)(8)
//   (4)(5)(6)let(9) name(12)(13):(15) String(14)(16)(10)(11)
// }
//
// (0) StructDeclSyntax(
//         attributes: AttributeListSyntax,
//         modifiers: DeclModifierListSyntax,
//         structKeyword: keyword(SwiftSyntax.Keyword.struct),
//         name: identifier("Person"),
//         memberBlock: MemberBlockSyntax
//     )
// (1) TokenSyntax(kind: keyword(SwiftSyntax.Keyword.struct), text: struct)
// (2) TokenSyntax(kind: identifier("Person"), text: Person)
// (3) MemberBlockSyntax(members: MemberBlockItemListSyntax)
// (4) MemberBlockItemListSyntax(Element: MemberBlockItemSyntax)
// (5) MemberBlockItemSyntax(decl: VariableDeclSyntax)
// (6) VariableDeclSyntax(attributes: AttributeListSyntax, modifiers: DeclModifierListSyntax, bindings: PatternBindingListSyntax)
// (7) AttributeListSyntaxSyntax(Element: Element)
// (8) DeclModifierListSyntax(Element: DeclModifierSyntax)
// (9) TokenSyntax(kind: keyword(SwiftSyntax.Keyword.let))
// (10) PatternBindingListSyntax(Element: PatternBindingSyntax)
// (11) PatternBindingSyntax(pattern: IdentifierPatternSyntax, typeAnnotation: TypeAnnotationSyntax)
// (12) IdentifierPatternSyntax(identifier: name("identifier"))
// (13) TokenSyntax(kind: identifier("name"), text: name)
// (14) TypeAnnotationSyntax(colon: colon, type: IdentifierTypeSyntax)
// (15) TokenSyntax(kind: colon, text: :)
// (16) IdentifierTypeSyntax(name: identifier("String"))
public struct CustomBuilderMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // 構造体のみを抽出
        guard let structDeclaration = declaration.as(StructDeclSyntax.self) else {
            return []
        }

        // MemberBlockItemSyntaxからIdentifierPatternSyntaxのidentifierを取り出す(例でのnameという変数名)
        func getIdentifierMember(_ member: MemberBlockItemSyntax) throws -> TokenSyntax {
            guard let identifier = member.decl.as(VariableDeclSyntax.self)?.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier else {
                throw "Missing identifier on member"
            }

            return identifier
        }

        // MemberBlockItemSyntaxからTypeAnnotationSyntaxのtype(型)を取り出す(例でのStringという型)
        func getTypeFromMember(_ member: MemberBlockItemSyntax) throws -> TypeSyntax {
            guard let type = member.decl.as(VariableDeclSyntax.self)?.bindings.first?.typeAnnotation?.as(TypeAnnotationSyntax.self)?.type else {
                throw "Missing type on member"
            }

            return type
        }

        // 「構造体名+Builder」という名前を生成(構造体名Personの場合はPersonBuilder)
        // `trailingTrivia`を使用して右にスペース1つ分空ける(この後に「{」をつけるため)
        let structName = TokenSyntax
            .identifier(structDeclaration.name.text + "Builder")
            .with(\.trailingTrivia, .spaces(1))

        // 構造体の全てのプロパティ名、型名抽出(例での`name`, `String型`)
        let members: [Member] = try structDeclaration.memberBlock.members
            .map { (identifier: try getIdentifierMember($0), type: try getTypeFromMember($0)) }

        // MemberBlockItemSyntaxからVariableDeclSyntaxを生成(プロパティ生成、例でのlet name: Stringの部分)
        func getMemberVaiable(member: Member) -> VariableDeclSyntax {
            VariableDeclSyntax(
                bindingSpecifier: .keyword(.var),
                bindings: PatternBindingListSyntax([
                    PatternBindingSyntax(
                        pattern: IdentifierPatternSyntax(identifier: member.identifier),
                        typeAnnotation: TypeAnnotationSyntax(type: member.type),
                        initializer: InitializerClauseSyntax(value: ExprSyntax(stringLiteral: "\"\""))
                    )
                ])
            )
        }

        // 関数でreturnされる中身作成
        // calledExpression: 構造体名「Person」
        // leftParen: 「(」のこと(引数内のtrailingTriviaで右側に処理「改行してさらにスペースを4つ分空ける」)
        // arguments: 中身
        //     label: ラベル名(プロパティ名)「name」
        //     expression: 値(プロパティ名)「name」
        // rightParen: 「)」のこと(引数内のleadingTriviaで左側に処理「改行する」)
        //
        // ※ trimmed: leadingTrivia, trailingTraviaを取り除く
        let returnStatement = ReturnStmtSyntax(
            expression: ExprSyntax(
                FunctionCallExprSyntax(
                    calledExpression: DeclReferenceExprSyntax(baseName: structDeclaration.name.trimmed),
                    leftParen: .leftParenToken(trailingTrivia: .newline.appending(Trivia.spaces(4))),
                    arguments: LabeledExprListSyntax {
                        for member in members {
                            LabeledExprSyntax(
                                label: member.identifier.text,
                                expression: ExprSyntax(stringLiteral: member.identifier.text))
                        }
                    },
                    rightParen: .rightParenToken(leadingTrivia: .newline)
                )
            )
        )

        // 関数の作成
        // name: 関数名「build」
        // signature: 関数の情報
        //     parameterClause: 引数情報(今回は不要なため空配列)
        //     returnClause: 戻り値(TypeSyntaxで型指定、型名は構造体名)
        let buildFunction = FunctionDeclSyntax(
            name: .identifier("build"),
            signature: FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax(parameters: FunctionParameterListSyntax([])),
                returnClause: ReturnClauseSyntax(type: TypeSyntax(stringLiteral: structDeclaration.name.text))
            ),
            bodyBuilder: {
                // 関数内の中身
                CodeBlockItemListSyntax([
                    CodeBlockItemListSyntax.Element(
                        item: CodeBlockItemListSyntax.Element.Item.stmt(StmtSyntax(returnStatement))
                    )
                ])
            }
        )

        // 構造体の作成
        // name: 構造体名「PersonBuilder」
        // memberBlockBuilder: 構造体が持つ関数「build()」
        let structureDeclaration = StructDeclSyntax(
            name: structName,
            memberBlockBuilder: {
                MemberBlockItemListSyntax {
                    for member in members {
                        MemberBlockItemSyntax(decl: getMemberVaiable(member: member))
                    }
                    MemberBlockItemListSyntax.Element(leadingTrivia: .newlines(2), decl: buildFunction)
                }
            }
        )

        return [DeclSyntax(structureDeclaration)]
    }
}
