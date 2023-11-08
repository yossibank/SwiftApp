import SwiftUI
import UIKit
import Utility

public final class PokemonViewController: SwiftUIViewController<PokemonView> {
    private let viewModel: PokemonViewModel

    public init(viewModel: PokemonViewModel) {
        self.viewModel = viewModel
        super.init(contentView: .init(viewModel: viewModel))
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
    }
}
