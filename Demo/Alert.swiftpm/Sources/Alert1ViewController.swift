import Combine
import SnapKit
import UIKit

final class Alert1ViewController: UIViewController {
    private let button: UIButton = {
        $0.setTitle("アラート表示", for: .normal)
        return $0
    }(UIButton(type: .system))

    private let alertManager = AlertManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTitle()
        setupEvent()
        setupAlert()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        alertManager.showAlertIfNeeded(rootViewController: self)
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
                self?.showAlert()
            },
            for: .touchUpInside
        )
    }

    private func setupAlert() {
        alertManager.addAlert(
            priority: .medium,
            alert: Alert2ViewController()
        )

        alertManager.addAlert(
            priority: .low,
            alert: Alert3ViewController()
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
            guard let self else {
                return
            }
            alertManager.showAlertIfNeeded(rootViewController: self)
        }

        alert.addAction(okAction)
        alert.addAction(cancelAction)

        alertManager.addAlert(
            priority: .high,
            alert: alert
        )

        alertManager.activate()
        alertManager.showAlertIfNeeded(rootViewController: self)
    }
}
