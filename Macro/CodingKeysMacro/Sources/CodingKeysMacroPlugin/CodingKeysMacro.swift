import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct CodingKeysPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        CodingKeysMacro.self
    ]
}

public struct CodingKeysMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let (option, structDecl) = decodeExpansion(of: node, attachedTo: declaration, in: context) else {
            return []
        }

        let properties = getProperties(decl: structDecl)

        guard diagnoseInvalidProperties(
            option: option,
            properties: properties,
            structName: structDecl.name.text,
            declaration: declaration,
            in: context
        ) else {
            return []
        }

        let generator = CodingKeysGenerator(
            option: option,
            properties: properties
        )

        let decl = generator
            .generate()
            .formatted()
            .as(EnumDeclSyntax.self)!

        return [DeclSyntax(decl)]
    }

    private static func getProperties(decl: StructDeclSyntax) -> [String] {
        var properties = [String]()

        for decl in decl.memberBlock.members.map(\.decl) {
            if let variableDecl = decl.as(VariableDeclSyntax.self) {
                properties.append(
                    contentsOf: variableDecl.bindings.compactMap {
                        $0.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
                    }
                )
            }
        }

        return properties
    }

    private static func diagnoseInvalidProperties(
        option: CodingKeysOption,
        properties: [String],
        structName: String,
        declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) -> Bool {
        let invalidProperties = option.necessaryProperties.compactMap {
            !properties.contains($0) ? $0 : nil
        }

        if !invalidProperties.isEmpty {
            context.diagnose(
                CodingKeysMacroDiagnostic.nonexistentProperty(
                    structName: structName,
                    propertyName: invalidProperties.joined(separator: ", ")
                )
                .diagnose(at: declaration)
            )
        }

        return invalidProperties.isEmpty
    }
}
