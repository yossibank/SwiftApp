import SwiftUI

struct RootView: View {
    @StateObject var viewModel: RootViewModel

    init(viewModel: RootViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Text("HOGE")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            HStack(spacing: 24) {
                SystemImageButton(
                    systemName: "plus.circle",
                    didTap: {
                        viewModel.didTapCreateButton()
                    }
                )
                SystemImageButton(
                    systemName: "magnifyingglass.circle",
                    didTap: {
                        viewModel.didTapSearchButton()
                    }
                )
            }
            .padding(32)
        }
    }

    private struct SystemImageButton: View {
        let systemName: String
        let didTap: () -> Void

        var body: some View {
            Button(
                action: didTap,
                label: {
                    Image(systemName: systemName)
                        .resizable()
                        .frame(width: 48, height: 48)
                }
            )
        }
    }
}
