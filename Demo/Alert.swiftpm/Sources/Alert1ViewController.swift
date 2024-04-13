import SnapKit
import UIKit

final class Alert1ViewController: UIViewController {
    private let button: UIButton = {
        $0.setTitle("アラート表示", for: .normal)
        return $0
    }(UIButton(type: .system))

    private var isShowAlert = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTitle()
        setupEvent()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if isShowAlert {
            present(
                Alert5ViewController(),
                animated: true
            )

            isShowAlert = false
        }
    }

    private func setupView() {
        view.backgroundColor = .white
        view.addSubview(button)

        button.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    private func setupTitle() {
        navigationItem.title = "Alert1"
    }

    private func setupEvent() {
        button.addAction(
            .init { [weak self] _ in
                self?.isShowAlert = true
                self?.showAlert()
            },
            for: .touchUpInside
        )
    }

    private func showAlert() {
        let alert = UIAlertController(
            title: "アラート",
            message: "アラート表示です",
            preferredStyle: .alert
        )

        let okAction = UIAlertAction(
            title: "OK",
            style: .default
        ) { [weak self] _ in
            self?.navigationController?.pushViewController(
                Alert4ViewController(),
                animated: true
            )
        }

        let cancelAction = UIAlertAction(
            title: "キャンセル",
            style: .cancel
        ) { [weak self] _ in
            self?.present(
                Alert5ViewController(),
                animated: true
            )
        }

        alert.addAction(okAction)
        alert.addAction(cancelAction)

        present(
            alert,
            animated: true
        )
    }
}
