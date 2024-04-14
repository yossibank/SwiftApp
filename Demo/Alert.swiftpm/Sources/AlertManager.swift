import UIKit

final class AlertManager {
    static let shared = AlertManager()

    private var isActivate = false
    private var alertQueues: [AlertQueue] = []

    func addAlert(
        priority: AlertQueue.Priority = .medium,
        alert: UIViewController
    ) {
        alertQueues.append(
            .init(
                priority: priority,
                alert: alert
            )
        )
    }

    func showAlertIfNeeded(rootViewController: UIViewController) {
        guard
            isActivate,
            let alertQueue = alertQueues.sorted(by: { $0.priority.rawValue < $1.priority.rawValue }).first
        else {
            return
        }

        rootViewController.present(
            alertQueue.alert,
            animated: true
        ) { [weak self] in
            self?.alertQueues.removeAll {
                $0.id == alertQueue.id
            }
        }
    }

    func activate() {
        isActivate = true
    }
}

struct AlertQueue {
    var id: String = UUID().uuidString
    var priority: Priority
    var alert: UIViewController

    enum Priority: Int {
        case high
        case medium
        case low
    }
}
