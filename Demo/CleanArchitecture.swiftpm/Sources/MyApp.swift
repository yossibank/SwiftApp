import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            let viewModel: GitHubRepositoryViewModel = {
                let repository = GitHubRepository()
                let useCase = GitHubRepositoryUseCase(repository: repository)
                let viewModel = GitHubRepositoryViewModel(useCase: useCase)
                return viewModel
            }()

            GitHubRepositoryView(viewModel: viewModel)
        }
    }
}
