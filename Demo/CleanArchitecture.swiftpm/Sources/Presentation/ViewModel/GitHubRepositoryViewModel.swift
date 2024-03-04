import Foundation

@MainActor
final class GitHubRepositoryViewModel: ObservableObject {
    @Published var repositories: [GitHubRepositoryEntity] = []

    private let useCase: GithubRepositoryUseCaseProtocol

    init(useCase: GithubRepositoryUseCaseProtocol) {
        self.useCase = useCase
    }

    func search(query: String) async {
        do {
            repositories = try await useCase.execute(query: query)
        } catch {
            print(error)
        }
    }
}
