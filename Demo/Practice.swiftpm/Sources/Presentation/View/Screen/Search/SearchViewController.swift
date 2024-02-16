import SwiftUI
import UIKit

final class SearchViewController: UIHostingController<SearchView> {
    init() {
        super.init(rootView: SearchView())
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
