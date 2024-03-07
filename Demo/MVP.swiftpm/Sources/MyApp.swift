import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            GitHubRepositoryView(
                presenter: GitHubRepositoryPresenter(
                    model: GitHubRepositoryModel(
                        apiClient: APIClient()
                    )
                )
            )
        }
    }
}
