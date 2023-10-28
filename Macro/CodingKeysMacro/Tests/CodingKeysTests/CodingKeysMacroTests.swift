@testable import CodingKeys
@testable import CodingKeysMacroPlugin
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

let testMacros: [String: Macro.Type] = [
    "CodingKeys": CodingKeysMacro.self
]

final class CodingKeysMacroTests: XCTestCase {
    func test_option_all() throws {
        assertMacroExpansion(
            """
            @CodingKeys(.all)
            public struct Hoge {
                let hogeHoge: String
                let fugaFuga: String
                let hoge: String
                let fuga: String
            }
            """,
            expandedSource: """
            public struct Hoge {
                let hogeHoge: String
                let fugaFuga: String
                let hoge: String
                let fuga: String

                enum CodingKeys: String, CodingKey {
                    case hogeHoge = "hoge_hoge"
                    case fugaFuga = "fuga_fuga"
                    case hoge
                    case fuga
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_option_select() throws {
        assertMacroExpansion(
            """
            @CodingKeys(.select(["hogeHoge", "hoge"])
            public struct Hoge {
                let hogeHoge: String
                var fugaFuga: String
                let hoge: String
                var fuga: String
            }
            """,

            expandedSource: """
            public struct Hoge {
                let hogeHoge: String
                var fugaFuga: String
                let hoge: String
                var fuga: String

                enum CodingKeys: String, CodingKey {
                    case hogeHoge = "hoge_hoge"
                    case fugaFuga
                    case hoge
                    case fuga
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_option_exclude() throws {
        assertMacroExpansion(
            """
            @CodingKeys(.exclude(["hogeHoge", "fooFoo"])
            public struct Hoge {
                let hogeHoge: String
                var fugaFuga: String
                let fooFoo: String
                var hogeHogeHoge: String
            }
            """,
            expandedSource: """
            public struct Hoge {
                let hogeHoge: String
                var fugaFuga: String
                let fooFoo: String
                var hogeHogeHoge: String

                enum CodingKeys: String, CodingKey {
                    case hogeHoge
                    case fugaFuga = "fuga_fuga"
                    case fooFoo
                    case hogeHogeHoge = "hoge_hoge_hoge"
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_option_custom() throws {
        assertMacroExpansion(
            """
            @CodingKeys(.custom(["id": "hoge_id", "hogeHoge": "hogee"])
            public struct Hoge {
                let id: String
                let hogeHoge: String
                var fugaFuga: String
                let fooFoo: String
                var hogeHogeHoge: String
            }
            """,
            expandedSource: """
            public struct Hoge {
                let id: String
                let hogeHoge: String
                var fugaFuga: String
                let fooFoo: String
                var hogeHogeHoge: String

                enum CodingKeys: String, CodingKey {
                    case id = "hoge_id"
                    case hogeHoge = "hogee"
                    case fugaFuga = "fuga_fuga"
                    case fooFoo = "foo_foo"
                    case hogeHogeHoge = "hoge_hoge_hoge"
                }
            }
            """,
            macros: testMacros
        )
    }
}
