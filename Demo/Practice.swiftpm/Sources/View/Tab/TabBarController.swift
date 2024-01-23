import SwiftUI
import UIKit

final class TabBarController: UITabBarController {
    private enum TabItem: Int, CaseIterable {
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
            let viewController: UIViewController

            switch self {
            case .todo:
                viewController = ToDoViewController()
                viewController.title = "やることリスト"

            case .news:
                viewController = NewsViewController()
                viewController.title = "ニュースリスト"
            }

            return viewController
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

    override func viewDidLoad() {
        super.viewDidLoad()

        setViewControllers(
            TabItem.allCases.map(\.rootViewController),
            animated: false
        )
    }
}
