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
                case let .detail(item):
                    self?.navigationController?.pushViewController(
                        DetailViewController(item: item),
                        animated: true
                    )

                case .create:
                    self?.navigationController?.pushViewController(
                        CreateViewController(),
                        animated: true
                    )

                case .search:
                    self?.navigationController?.pushViewController(
                        SearchViewController(
                            viewModel: SearchViewModel(
                                state: .init(),
                                dependency: .init(
                                    apiClient: .init(),
                                    userDefaultsClient: .init(),
                                    translator: .init()
                                )
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
