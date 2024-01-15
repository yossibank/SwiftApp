import SwiftUI
import UIKit
import Utility

public final class PokemonViewController: UIHostingController<PokemonView> {
    private let viewModel: PokemonViewModel

    public init(viewModel: PokemonViewModel) {
        self.viewModel = viewModel
        super.init(rootView: .init(viewModel: viewModel))
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
    }
}
