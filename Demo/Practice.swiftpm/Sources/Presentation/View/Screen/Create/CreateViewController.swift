import SwiftUI
import UIKit

final class CreateViewController: UIHostingController<CreateView> {
    init() {
        super.init(rootView: CreateView())
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        title = "作成"
    }
}
