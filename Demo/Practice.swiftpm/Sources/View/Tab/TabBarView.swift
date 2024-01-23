import SwiftUI

struct TabBarView: View {
    var body: some View {
        TabBarControllerWrapper()
    }
}

private struct TabBarControllerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = TabBarController

    func makeUIViewController(context: Context) -> TabBarController {
        TabBarController()
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

#Preview {
    TabBarView()
}
