import SwiftUI
import UIKit

final class NewsViewController: UIHostingController<NewsView> {
    init() {
        super.init(rootView: NewsView())
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
