import SwiftUI

struct GitHubRepositoryView: View {
    @StateObject var presenter: GitHubRepositoryPresenter

    init(presenter: GitHubRepositoryPresenter) {
        self._presenter = .init(wrappedValue: presenter)
    }

    var body: some View {
        List(presenter.repositories, id: \.self) { repository in
            Text(repository.name)
                .bold()
        }
        .task {
            await presenter.fetch(query: "Swift")
        }
    }
}
