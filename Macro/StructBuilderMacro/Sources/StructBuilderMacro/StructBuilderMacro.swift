import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Implementation of the `stringify` macro, which takes an expression
/// of any type and produces a tuple containing the value of that expression
/// and the source code that produced the value. For example
///
///     #stringify(x + y)
///
///  will expand to
///
///     (x + y, "x + y")
public struct StringifyMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let argument = node.argumentList.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }

        return "(\(argument), \(literal: argument.description))"
    }
}

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

        // 構造体の全てのプロパティ名抽出(例での`name`)
        let members = structDeclaration.memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self)?.bindings.first }
            .compactMap { $0.pattern.as(IdentifierPatternSyntax.self) }

        // 「構造体名+Builder」という名前を生成(構造体名Personの場合はPersonBuilder)
        // `trailingTrivia`を使用して右にスペース1つ分空ける(この後に「{」をつけるため)
        let name = TokenSyntax
            .identifier(structDeclaration.name.text + "Builder")
            .with(\.trailingTrivia, .spaces(1))

        var returnStatement = ReturnStmtSyntax()
        // 関数でreturnされる中身作成
        // calledExpression: 構造体名「Person」
        // leftParen: 「(」のこと(引数内のtrailingTriviaで右側に処理「改行してさらにスペースを4つ分空ける」)
        // arguments: 中身
        //     label: ラベル名(プロパティ名)「name」
        //     expression: 値(プロパティ名)「name」
        // rightParen: 「)」のこと(引数内のleadingTriviaで左側に処理「改行する」)
        //
        // ※ trimmed: leadingTrivia, trailingTraviaを取り除く
        returnStatement.expression = ExprSyntax(
            FunctionCallExprSyntax(
                calledExpression: DeclReferenceExprSyntax(baseName: structDeclaration.name.trimmed),
                leftParen: .leftParenToken(trailingTrivia: .newline.appending(Trivia.spaces(4))),
                arguments: LabeledExprListSyntax(
                    members.map { member in
                        LabeledExprSyntax(
                            label: member.identifier.text,
                            expression: ExprSyntax(stringLiteral: member.identifier.text)
                        )
                    }
                ),
                rightParen: .rightParenToken(leadingTrivia: .newline)
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
            )
        ) {
            // 関数内の中身
            CodeBlockItemListSyntax([
                CodeBlockItemListSyntax.Element(
                    item: CodeBlockItemListSyntax.Element.Item.stmt(StmtSyntax(returnStatement))
                )
            ])
        }

        // 構造体の作成
        // name: 構造体名「PersonBuilder」
        // memberBlockBuilder: 構造体が持つ関数「build()」
        let structureDeclaration = StructDeclSyntax(
            name: name,
            memberBlockBuilder: {
                MemberBlockItemListSyntax([
                    MemberBlockItemListSyntax.Element(decl: buildFunction)
                ])
            }
        )

        return [DeclSyntax(structureDeclaration)]
    }
}

@main
struct StructBuilderPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StringifyMacro.self,
        CustomBuilderMacro.self
    ]
}
