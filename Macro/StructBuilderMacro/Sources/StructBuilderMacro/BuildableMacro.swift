import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct BuildablePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        BuildableMacro.self
    ]
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

/// Implementation of the `Buildable` macro, which takes a struct declaration
/// and produces a peer struct which implements the builder pattern
///
///     @Buildable
///     struct Person {
///         name: String
///         age: Int
///         address: Address
///     }
///
/// will expand to
///
///     struct Person {
///         let name: String
///         let age: Int
///         let address: Address
///     }
///
///     struct PersonBuilder {
///         var name: String = ""
///         var age: Int = 0
///         var address: Address = AddressBuilder().build()
///
///         func build() -> Person {
///             return Person(
///                 name: name,
///                 age: age,
///                 address: address
///             )
///         }
///     }
public struct BuildableMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // 構造体のみを抽出
        guard let structDeclaration = declaration.as(StructDeclSyntax.self) else {
            throw "Macro can only be applied to structs"
        }

        // 構造体の全てのプロパティ名、型名抽出(例での`name`, `String型`)
        let members: [Member] = MemberMapper.mapFrom(members:structDeclaration.memberBlock.members)

        // 「構造体名+Builder」という名前を生成(構造体名Personの場合はPersonBuilder)
        // `trailingTrivia`を使用して右にスペース1つ分空ける(この後に「{」をつけるため)
        let structName = TokenSyntax
            .identifier(structDeclaration.name.text + "Builder")
            .with(\.trailingTrivia, .spaces(1))

        // 構造体の作成
        // name: 構造体名「PersonBuilder」
        // memberBlockBuilder: 構造体が持つ関数「build()」
        let structureDeclaration = StructDeclSyntax(name: structName) {
            MemberBlockItemListSyntax {
                for member in members {
                    MemberBlockItemSyntax(decl: VariableDeclFactory.makeMemberVaiable(member: member))
                }
                MemberBlockItemListSyntax.Element(
                    leadingTrivia: .newlines(2),
                    decl: FunctionDeclFactory.makeFunctionDeclFrom(
                        structDeclaration: structDeclaration,
                        members: members
                    )
                )
            }
        }

        return [DeclSyntax(structureDeclaration)]
    }
}
