import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public extension CodingKeysMacro {
    static func decodeExpansion(
        of attribute: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) -> (CodingKeysOption, StructDeclSyntax)? {
        guard
            case let .argumentList(arguments) = attribute.arguments,
            let firstElement = arguments.first?.expression
        else {
            context.diagnose(CodingKeysMacroDiagnostic.noArgument.diagnose(at: attribute))
            return nil
        }

        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            context.diagnose(CodingKeysMacroDiagnostic.requiresStruct.diagnose(at: attribute))
            return nil
        }

        if let memberAccessExpr = firstElement.as(MemberAccessExprSyntax.self),
           let option = decodeMemberAccess(of: attribute, expr: memberAccessExpr, in: context) {
            return (option, structDecl)
        }

        if let functionCallExpr = firstElement.as(FunctionCallExprSyntax.self),
           let option = decodeFunctionCall(of: attribute, expr: functionCallExpr, in: context) {
            return (option, structDecl)
        }

        context.diagnose(CodingKeysMacroDiagnostic.invalidArgument.diagnose(at: attribute))
        return nil
    }

    private static func decodeMemberAccess(
        of attribute: AttributeSyntax,
        expr memberAccessExpr: MemberAccessExprSyntax,
        in context: some MacroExpansionContext
    ) -> CodingKeysOption? {
        if memberAccessExpr.declName.baseName.trimmedDescription == "all" {
            return .all
        } else {
            context.diagnose(CodingKeysMacroDiagnostic.noArgument.diagnose(at: attribute))
            return nil
        }
    }

    private static func decodeFunctionCall(
        of attribute: AttributeSyntax,
        expr functionCallExpr: FunctionCallExprSyntax,
        in context: some MacroExpansionContext
    ) -> CodingKeysOption? {
        guard
            let caseName = functionCallExpr.calledExpression.as(MemberAccessExprSyntax.self)?.declName.baseName.text,
            let expression = functionCallExpr.arguments.first?.expression
        else {
            context.diagnose(CodingKeysMacroDiagnostic.noArgument.diagnose(at: attribute))
            return nil
        }

        if let arrayExpr = expression.as(ArrayExprSyntax.self),
           let stringArray = arrayExpr.stringArray {
            return .associatedValueArray(
                caseName,
                associatedValue: stringArray
            )
        }

        if let dictionaryElements = expression.as(DictionaryExprSyntax.self),
           let stringDictionary = dictionaryElements.stringDictionary {
            return .associatedValueDictionary(
                caseName,
                associatedValue: stringDictionary
            )
        }

        context.diagnose(CodingKeysMacroDiagnostic.invalidArgument.diagnose(at: attribute))
        return nil
    }
}

private extension ArrayExprSyntax {
    var stringArray: [String]? {
        elements.reduce(into: [String]()) { result, element in
            guard let string = element.expression.as(StringLiteralExprSyntax.self) else {
                return
            }

            result.append(string.rawValue)
        }
    }
}

private extension DictionaryExprSyntax {
    var stringDictionary: [String: String]? {
        guard let elements = content.as(DictionaryElementListSyntax.self) else {
            return nil
        }

        return elements.reduce(into: [String: String]()) { result, element in
            guard
                let key = element.key.as(StringLiteralExprSyntax.self),
                let value = element.value.as(StringLiteralExprSyntax.self)
            else {
                return
            }

            result.updateValue(
                value.rawValue,
                forKey: key.rawValue
            )
        }
    }
}

private extension StringLiteralExprSyntax {
    var rawValue: String {
        segments
            .compactMap { $0.as(StringSegmentSyntax.self) }
            .map(\.content.text)
            .joined()
    }
}
