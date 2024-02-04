import SwiftUI
import UIKit

final class ListViewController: UIHostingController<ListView> {
    init() {
        super.init(rootView: ListView())
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
