import SwiftUI
import UIKit

final class TabBarController: UITabBarController {
    private enum TabItem: Int, CaseIterable {
        case home
        case list

        private var title: String {
            switch self {
            case .home: "HOME"
            case .list: "LIST"
            }
        }

        private var image: UIImage {
            switch self {
            case .home: UIImage(systemName: "house.fill") ?? .init()
            case .list: UIImage(systemName: "list.dash") ?? .init()
            }
        }

        private var baseViewController: UIViewController {
            let viewController: UIViewController

            switch self {
            case .home:
                viewController = HomeViewController()
                viewController.title = "ホーム"

            case .list:
                viewController = ListViewController()
                viewController.title = "リスト"
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

private extension UIImage {
    func resized(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { _ in
            draw(in: .init(origin: .zero, size: size))
        }
    }
}
