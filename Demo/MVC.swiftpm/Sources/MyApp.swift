import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            GitHubRepositoryView(
                model: GitHubRepositoryModel(
                    apiClient: APIClient()
                )
            )
        }
    }
}
