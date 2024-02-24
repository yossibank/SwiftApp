import SwiftUI
import UIKit

final class DetailViewController: UIHostingController<DetailView> {
    init(item: ProductModel) {
        super.init(rootView: DetailView(item: item))
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
        title = "商品詳細"
    }
}
