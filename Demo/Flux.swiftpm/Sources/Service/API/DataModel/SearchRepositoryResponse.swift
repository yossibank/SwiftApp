import Foundation
import SwiftUI

struct SearchRepositoryResponse: Decodable {
    var items: [Repository]
}

struct Repository: Decodable, Hashable, Identifiable {
    var id: Int64
    var fullName: String
    var description: String?
    var stargazersCount = 0
    var language: String?
    var owner: User
}

struct User: Decodable, Hashable, Identifiable {
    var id: Int64
    var login: String
    var avatarUrl: URL
}
