import SwiftUI
import UIKit

final class HomeViewController: UIHostingController<HomeView> {
    init() {
        super.init(rootView: HomeView())
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        Task { @MainActor in
            do {
                try await request()
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func request() async throws {
        let response = try await APIClient().request(
            item: RakutenProductSearchRequest(parameters: .init(keyword: "楽天"))
        )

        print(response)
    }
}
