import SwiftUI

struct GitHubListView: View {
    @StateObject var store: GitHubListStore = .shared

    @State private var path = [Repository]()

    private var actionCreator: GitHubActionCreator

    init(actionCreator: GitHubActionCreator = .init()) {
        self.actionCreator = actionCreator
    }

    var body: some View {
        NavigationStack(path: $path) {
            List(store.repositories) { repository in
                NavigationLink(value: repository) {
                    Text(repository.fullName)
                }
            }
            .alert("Error", isPresented: $store.isShownError) {}
            .navigationTitle(Text("Repositories"))
            .navigationDestination(for: Repository.self) { repository in
                GitHubRowView(repository: repository, path: $path)
            }
        }
        .onAppear {
            actionCreator.onAppear()
        }
    }
}

#Preview {
    GitHubListView()
}
