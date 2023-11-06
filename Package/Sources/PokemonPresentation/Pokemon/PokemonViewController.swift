import SwiftUI
import UIKit
import Utility

public final class PokemonViewController: UIViewController {
    private let viewModel: PokemonViewModel

    public init(viewModel: PokemonViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        setView(PokemonView(viewModel: viewModel))
    }
}
