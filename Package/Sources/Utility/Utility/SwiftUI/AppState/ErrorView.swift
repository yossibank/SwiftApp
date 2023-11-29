import AppResources
import SwiftUI

public struct ErrorView: View {
    let errorDescription: String?
    let didTapReloadButton: () -> Void

    public init(
        errorDescription: String?,
        didTapReloadButton: @escaping () -> Void
    ) {
        self.errorDescription = errorDescription
        self.didTapReloadButton = didTapReloadButton
    }

    public var body: some View {
        VStack(spacing: 24) {
            Asset.error.swiftUIImage
                .resizable()
                .frame(width: 80, height: 80)

            Text(L10n.Utility.errorOccurred)
                .font(.headline)

            VStack(spacing: 8) {
                Text(L10n.Utility.cause)
                    .font(.subheadline)
                    .bold()

                Text(errorDescription ?? L10n.Utility.unknownError)
                    .font(.subheadline)
                    .bold()
            }

            Button {
                didTapReloadButton()
            } label: {
                Text(L10n.Utility.reload)
                    .font(.subheadline)
                    .bold()
                    .foregroundStyle(.pink)
                    .padding(8)
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.pink, lineWidth: 1)
                    }
            }
        }
    }
}

#Preview {
    ErrorView(errorDescription: "通信エラー") {}
}
