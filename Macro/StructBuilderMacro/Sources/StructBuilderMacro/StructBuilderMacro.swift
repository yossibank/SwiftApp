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

public struct CustomBuilderMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // 木構造はここで調べながら検証
        // https://swift-ast-explorer.com/
        guard let structDeclaration = declaration.as(StructDeclSyntax.self) else {
            return []
        }

        let members = structDeclaration.memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self)?.bindings.first }
            .compactMap { $0.pattern.as(IdentifierPatternSyntax.self) }

        let name = TokenSyntax
            .identifier(structDeclaration.name.text + "Builder")
            .with(\.trailingTrivia, .spaces(1))

        var returnStatement = ReturnStmtSyntax()
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

        let buildFunction = FunctionDeclSyntax(
            name: .identifier("build"),
            signature: FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax(parameters: FunctionParameterListSyntax([])),
                returnClause: ReturnClauseSyntax(type: TypeSyntax(stringLiteral: structDeclaration.name.text))
            )
        ) {
            CodeBlockItemListSyntax([
                CodeBlockItemListSyntax.Element(
                    item: CodeBlockItemListSyntax.Element.Item.stmt(StmtSyntax(returnStatement))
                )
            ])
        }

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
