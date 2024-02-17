import Foundation

/// データのベースとなる構造体が準拠しているべきものをまとめたプロトコル
/// CodableとEquatableに準拠していることを明確にしている
protocol DataStructure: Codable, Equatable {}
