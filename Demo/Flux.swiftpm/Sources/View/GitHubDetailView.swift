import SwiftUI

struct GitHubDetailView: View {
    var text: String

    var body: some View {
        Text(text)
    }
}

#Preview {
    GitHubDetailView(text: "github")
}
