import Combine
import SwiftUI

final class GitHubListStore: ObservableObject {
    static let shared = GitHubListStore()

    @Published private(set) var repositories: [Repository] = []
    @Published private(set) var errorMessage = ""
    @Published var isShownError = false
    @Published var shouldShowIcon = false

    init(dispatcher: GitHubListDispatcher = .shared) {
        dispatcher.register { [weak self] action in
            guard let self else {
                return
            }

            switch action {
            case let .updateRepositories(repositories):
                self.repositories = repositories
            case let .updateErrorMessage(message):
                self.errorMessage = message
            case .showError:
                self.isShownError = true
            case .showIcon:
                break
            }
        }
    }
}
