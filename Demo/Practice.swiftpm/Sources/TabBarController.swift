import SwiftUI
import UIKit

enum TabItem: Int, CaseIterable {
    case todo
    case news

    private var title: String {
        switch self {
        case .todo: "TODO"
        case .news: "NEWS"
        }
    }

    private var image: UIImage {
        switch self {
        case .todo: UIImage(systemName: "list.bullet.circle") ?? .init()
        case .news: UIImage(systemName: "newspaper.circle") ?? .init()
        }
    }

    private var baseViewController: UIViewController {
        switch self {
        case .todo: ToDoViewController()
        case .news: NewsViewController()
        }
    }

    var rootViewController: UIViewController {
        let rootViewController = UINavigationController(
            rootViewController: baseViewController
        )

        rootViewController.tabBarItem = .init(
            title: title,
            image: image
                .resized(size: .init(width: 24, height: 24))
                .withRenderingMode(.alwaysOriginal),
            tag: rawValue
        )

        return rootViewController
    }
}

struct TabBarView: View {
    var body: some View {
        TabBarControllerWrapper()
    }
}

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setViewControllers(
            TabItem.allCases.map(\.rootViewController),
            animated: false
        )
    }
}

private struct TabBarControllerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = TabBarController

    func makeUIViewController(context: Context) -> TabBarController {
        TabBarController()
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

final class ToDoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .red
        title = "TODO"
    }
}

final class NewsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .yellow
        title = "NEWS"
    }
}
