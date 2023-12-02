import Foundation

enum GitHubListAction {
    case updateRepositories([Repository])
    case updateErrorMessage(String)
    case showError
    case showIcon
}
