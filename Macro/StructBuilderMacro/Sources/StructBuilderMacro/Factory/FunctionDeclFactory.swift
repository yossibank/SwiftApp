import SwiftSyntax

struct FunctionDeclFactory {
    static func makeFunctionDeclFrom(
        structDeclaration: StructDeclSyntax,
        members: [Member]
    ) -> FunctionDeclSyntax {
        // 関数でreturnされる中身作成
        // calledExpression: 構造体名「Person」
        // leftParen: 「(」のこと
        // arguments: 中身
        //     leadingTrivia: 「改行」
        //     label: ラベル名(プロパティ名)「TokenSyntax: name」
        //     colon: コロン「:」
        //     expression: 値(プロパティ名)「ExprSyntax: name」
        // rightParen: 「)」のこと(引数内のleadingTriviaで左側に処理「改行する」)
        //
        // ※ trimmed: leadingTrivia, trailingTraviaを取り除く
        let buildFunctionReturnStatement = ReturnStmtSyntax(
            expression: ExprSyntax(
                FunctionCallExprSyntax(
                    calledExpression: DeclReferenceExprSyntax(baseName: structDeclaration.name.trimmed),
                    leftParen: .leftParenToken(),
                    arguments: LabeledExprListSyntax {
                        for member in members {
                            LabeledExprSyntax(
                                leadingTrivia: .newline,
                                label: member.identifier,
                                colon: TokenSyntax(.colon, presence: .present),
                                expression: ExprSyntax(stringLiteral: member.identifier.text))
                        }
                    },
                    rightParen: .rightParenToken(leadingTrivia: .newline)
                )
            )
        )

        // 関数の情報作成
        // parameterClause: 引数情報(今回は不要なため空配列)
        // returnClause: 戻り値(TypeSyntaxで型指定、型名は構造体名)
        let buildFunctionSignature = FunctionSignatureSyntax(
            parameterClause: FunctionParameterClauseSyntax(parameters: FunctionParameterListSyntax([])),
            returnClause: ReturnClauseSyntax(type: TypeSyntax(stringLiteral: structDeclaration.name.text))
        )

        // 関数の作成
        // name: 関数名「build」
        // signature: 関数の情報「上のbuildFunctionSignature使用」
        return FunctionDeclSyntax(
            name: .identifier("build"),
            signature: buildFunctionSignature
        ) {
            // 関数内の中身
            CodeBlockItemListSyntax {
                CodeBlockItemSyntax(
                    item: CodeBlockItemListSyntax.Element.Item.stmt(StmtSyntax(buildFunctionReturnStatement))
                )
            }
        }
    }
}
