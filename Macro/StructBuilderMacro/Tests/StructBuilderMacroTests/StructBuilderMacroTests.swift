import StructBuilderMacro
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

let testMacros: [String: Macro.Type] = [
    "CustomBuilder": CustomBuilderMacro.self
]

final class StructBuilderMacroTests: XCTestCase {
    func test_macro_with_one_string_number() throws {
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

    func test_macro_with_two_string_number() throws {
        assertMacroExpansion(
            """
            @CustomBuilder
            struct Person {
                let name: String
                let middleName: String
            }
            """,
            expandedSource: """
            struct Person {
                let name: String
                let middleName: String
            }

            struct PersonBuilder {
                var name: String = ""
                var middleName: String = ""

                func build() -> Person {
                    return Person(
                        name: name,
                        middleName: middleName
                    )
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_macro_with_different_types() {
        assertMacroExpansion(
            """
            @CustomBuilder
            struct MyObject {
                let m01: String
                let m02: Int
                let m03: Int8
                let m04: Int16
                let m05: Int32
                let m06: Int64
                let m07: UInt
                let m08: UInt8
                let m09: UInt16
                let m10: UInt32
                let m11: UInt64
                let m12: Double
                let m13: Float
                let m14: Bool
                let m15: Date
                let m16: UUID
                let m17: Data
                let m18: URL
                let m19: CGFloat
                let m20: CGPoint
                let m21: CGRect
                let m22: CGSize
                let m23: CGVector
            }
            """,
            expandedSource: """
            struct MyObject {
                let m01: String
                let m02: Int
                let m03: Int8
                let m04: Int16
                let m05: Int32
                let m06: Int64
                let m07: UInt
                let m08: UInt8
                let m09: UInt16
                let m10: UInt32
                let m11: UInt64
                let m12: Double
                let m13: Float
                let m14: Bool
                let m15: Date
                let m16: UUID
                let m17: Data
                let m18: URL
                let m19: CGFloat
                let m20: CGPoint
                let m21: CGRect
                let m22: CGSize
                let m23: CGVector
            }

            struct MyObjectBuilder {
                var m01: String = ""
                var m02: Int = 0
                var m03: Int8 = 0
                var m04: Int16 = 0
                var m05: Int32 = 0
                var m06: Int64 = 0
                var m07: UInt = 0
                var m08: UInt8 = 0
                var m09: UInt16 = 0
                var m10: UInt32 = 0
                var m11: UInt64 = 0
                var m12: Double = 0
                var m13: Float = 0
                var m14: Bool = false
                var m15: Date = .now
                var m16: UUID = UUID()
                var m17: Data = Data()
                var m18: URL = URL(string: "https://www.google.com")!
                var m19: CGFloat = 0
                var m20: CGPoint = CGPoint()
                var m21: CGRect = CGRect()
                var m22: CGSize = CGSize()
                var m23: CGVector = CGVector()

                func build() -> MyObject {
                    return MyObject(
                        m01: m01,
                        m02: m02,
                        m03: m03,
                        m04: m04,
                        m05: m05,
                        m06: m06,
                        m07: m07,
                        m08: m08,
                        m09: m09,
                        m10: m10,
                        m11: m11,
                        m12: m12,
                        m13: m13,
                        m14: m14,
                        m15: m15,
                        m16: m16,
                        m17: m17,
                        m18: m18,
                        m19: m19,
                        m20: m20,
                        m21: m21,
                        m22: m22,
                        m23: m23
                    )
                }
            }
            """,
            macros: testMacros
        )
    }
}
