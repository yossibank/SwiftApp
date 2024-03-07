import Foundation

final class GitHubRepositoryPresenter: ObservableObject {
    @Published var repositories: [GitHubRepositoryEntity.Item] = []

    private let model: GitHubRepositoryModel

    init(model: GitHubRepositoryModel) {
        self.model = model
    }

    func fetch(query: String) async {
        do {
            let response = try await model.fetch(query: query)

            await MainActor.run {
                repositories = response
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
