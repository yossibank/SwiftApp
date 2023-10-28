import SwiftDiagnostics
import SwiftSyntax

public enum CodingKeysMacroDiagnostic {
    case nonexistentProperty(structName: String, propertyName: String)
    case noArgument
    case requiresStruct
    case invalidArgument
}

extension CodingKeysMacroDiagnostic: DiagnosticMessage {
    public var diagnosticID: MessageID {
        MessageID(domain: "Swift", id: "CodingKeysMacro.\(self)")
    }

    public var severity: DiagnosticSeverity {
        .error
    }

    public var message: String {
        switch self {
        case let .nonexistentProperty(structName, propertyName):
            "Property \(propertyName) does not exist in \(structName)"

        case .noArgument:
            "Cannot find argument"

        case .requiresStruct:
            "'CodingKeys' macro can only be applied to struct"

        case .invalidArgument:
            "Invalid argument"
        }
    }

    func diagnose(at node: some SyntaxProtocol) -> Diagnostic {
        Diagnostic(node: Syntax(node), message: self)
    }
}
