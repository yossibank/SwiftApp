import Foundation
import SwiftSyntax

struct TypeMapper {
    private static var mapping: [String: ExprSyntax] = [
        "String": "\"\"",
        "Int": "0",
        "Int8": "0",
        "Int16": "0",
        "Int32": "0",
        "Int64": "0",
        "UInt": "0",
        "UInt8": "0",
        "UInt16": "0",
        "UInt32": "0",
        "UInt64": "0",
        "Double": "0",
        "Float": "0",
        "Bool": "false",
        "Date": ".now",
        "UUID": "UUID()",
        "Data": "Data()",
        "URL": "URL(string: \"https://www.google.com\")!",
        "CGFloat": "0",
        "CGPoint": "CGPoint()",
        "CGRect": "CGRect()",
        "CGSize": "CGSize()",
        "CGVector": "CGVector()"
    ]

    static func getDefaultValueFor(type: TypeSyntax) -> ExprSyntax? {
        guard type.kind != .optionalType else {
            return nil
        }

        guard type.kind != .arrayType else {
            return ExprSyntax(stringLiteral: "[]")
        }

        guard let defaultValue = mapping[type.trimmedDescription] else {
            return ExprSyntax(stringLiteral: type.trimmedDescription + "Builder().build()")
        }

        return defaultValue
    }
}
