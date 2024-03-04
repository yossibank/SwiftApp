import SwiftUI

struct GitHubRepositoryView: View {
    @StateObject var viewModel: GitHubRepositoryViewModel

    init(viewModel: GitHubRepositoryViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }

    var body: some View {
        List(viewModel.repositories, id: \.self) { repository in
            Text(repository.name)
                .bold()
        }
        .task {
            await viewModel.search(query: "Swift")
        }
    }
}
