import SwiftUI
import UIKit

enum TabItem: Int, CaseIterable {
    case alert1
    case alert2
    case alert3

    var title: String {
        switch self {
        case .alert1: "アラート1"
        case .alert2: "アラート2"
        case .alert3: "アラート3"
        }
    }

    var image: UIImage? {
        switch self {
        case .alert1: .init(systemName: "pencil")
        case .alert2: .init(systemName: "eraser")
        case .alert3: .init(systemName: "paperplane")
        }
    }

    var rootViewController: UIViewController {
        let rootViewController = UINavigationController(
            rootViewController: baseViewController
        )

        rootViewController.tabBarItem = .init(
            title: title,
            image: image,
            tag: rawValue
        )

        return rootViewController
    }

    private var baseViewController: UIViewController {
        switch self {
        case .alert1: Alert1ViewController()
        case .alert2: Alert2ViewController()
        case .alert3: Alert3ViewController()
        }
    }
}

final class AlertTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setViewControllers(
            TabItem.allCases.map(\.rootViewController),
            animated: true
        )
    }
}

struct AlertTabBarControllerView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        AlertTabBarController()
    }

    func updateUIViewController(
        _ uiViewController: UIViewControllerType,
        context: Context
    ) {}
}
