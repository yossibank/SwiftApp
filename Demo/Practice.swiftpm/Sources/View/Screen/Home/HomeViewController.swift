import SwiftUI
import UIKit

final class HomeViewController: UIHostingController<HomeView> {
    init() {
        super.init(rootView: HomeView())
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
