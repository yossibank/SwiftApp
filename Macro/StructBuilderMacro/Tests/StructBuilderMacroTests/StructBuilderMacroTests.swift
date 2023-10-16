import StructBuilderMacro
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

let testMacros: [String: Macro.Type] = [
    "CustomBuilder": CustomBuilderMacro.self
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
            macros: testMacros
        )
    }
}
