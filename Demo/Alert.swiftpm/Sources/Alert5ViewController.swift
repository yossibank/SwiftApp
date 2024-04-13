import SnapKit
import UIKit

final class Alert5ViewController: UIViewController {
    private let label: UILabel = {
        $0.text = "Alert5"
        return $0
    }(UILabel())

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTitle()
    }

    private func setupView() {
        view.backgroundColor = .white
        view.addSubview(label)

        label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    private func setupTitle() {
        navigationItem.title = "Alert5"
    }
}
