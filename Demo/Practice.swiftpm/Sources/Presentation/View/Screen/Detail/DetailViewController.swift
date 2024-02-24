import SwiftUI
import UIKit

final class DetailViewController: UIHostingController<DetailView> {
    init() {
        super.init(rootView: DetailView())
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
