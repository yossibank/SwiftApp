import Combine
import SwiftUI
import UIKit

final class RootViewController: UIHostingController<RootView> {
    private var cancellables = Set<AnyCancellable>()
    private let viewModel: RootViewModel

    init(viewModel: RootViewModel) {
        self.viewModel = viewModel
        super.init(rootView: RootView(viewModel: viewModel))
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBinding()
    }

    private func setupView() {
        title = "ホーム"
    }

    private func setupBinding() {
        viewModel.output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                switch output {
                case .create:
                    print("作成画面遷移")

                case .search:
                    self?.navigationController?.pushViewController(
                        SearchViewController(
                            viewModel: SearchViewModel(
                                state: .init(),
                                dependency: .init()
                            )
                        ),
                        animated: true
                    )
                }
            }
            .store(in: &cancellables)
    }
}

struct RootViewControllerRepresentable: UIViewControllerRepresentable {
    let viewModel: RootViewModel

    func makeUIViewController(context: Context) -> some UIViewController {
        let rootViewController = RootViewController(viewModel: viewModel)
        return UINavigationController(rootViewController: rootViewController)
    }

    func updateUIViewController(
        _ uiViewController: UIViewControllerType,
        context: Context
    ) {}
}
