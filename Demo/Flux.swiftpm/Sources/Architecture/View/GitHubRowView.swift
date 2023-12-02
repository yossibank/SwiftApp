import SwiftUI

struct GitHubRowView: View {
    var repository: Repository

    @Binding var path: [Repository]

    var body: some View {
        VStack(spacing: 32) {
            Text(repository.fullName)
                .font(.title)

            Button("戻る") {
                path.removeLast()
            }
        }
    }
}

#Preview {
    GitHubRowView(
        repository: .init(
            id: 1,
            fullName: "github",
            owner: .init(
                id: 1,
                login: "login",
                avatarUrl: .init(string: "https://google.com")!
            )
        ),
        path: .constant([])
    )
}
