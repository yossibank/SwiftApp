import StructBuilderMacro
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

let testBuilderMacros: [String: Macro.Type] = [
    "CustomBuilder": CustomBuilderMacro.self
]

let testStringifyMacros: [String: Macro.Type] = [
    "stringify": StringifyMacro.self
]

final class StructBuilderMacroTests: XCTestCase {
    func testMacroWithCustomBuilder() throws {
        assertMacroExpansion(
            """
            @CustomBuilder
            struct Person {
                let name: String
            }
            """,
            expandedSource: """
            struct Person {
                let name: String
            }

            struct PersonBuilder {
                var name: String = ""

                func build() -> Person {
                    return Person(
                        name: name
                    )
                }
            }
            """,
            macros: testBuilderMacros
        )
    }

    func testMacroWithStringLiteral() throws {
        assertMacroExpansion(
            #"""
            #stringify("Hello, \(name)")
            """#,
            expandedSource: #"""
            ("Hello, \(name)", #""Hello, \(name)""#)
            """#,
            macros: testStringifyMacros
        )
    }
}
