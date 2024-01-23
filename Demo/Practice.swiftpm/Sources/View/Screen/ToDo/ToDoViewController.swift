import SwiftUI
import UIKit

final class ToDoViewController: UIHostingController<ToDoView> {
    init() {
        super.init(rootView: ToDoView())
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
