import Foundation

struct ToDo: Codable, Hashable {
    var isChecked: Bool
    let task: String
}
