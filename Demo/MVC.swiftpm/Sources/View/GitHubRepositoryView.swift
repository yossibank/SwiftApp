import SwiftUI

struct GitHubRepositoryView: View {
    @StateObject var model: GitHubRepositoryModel

    init(model: GitHubRepositoryModel) {
        self._model = .init(wrappedValue: model)
    }

    var body: some View {
        List(model.repositories, id: \.self) { repository in
            Text(repository.name)
                .bold()
        }
        .task {
            await model.fetch(query: "Swift")
        }
    }
}
