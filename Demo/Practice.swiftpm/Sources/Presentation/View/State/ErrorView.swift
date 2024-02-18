import SwiftUI

struct ErrorView: View {
    let errorDescription: String?
    let didTapReloadButton: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image("error", bundle: .module)
                .resizable()
                .frame(width: 80, height: 80)

            Text("エラーが発生しました")
                .font(.headline)

            VStack(spacing: 8) {
                Text("【原因】")
                    .font(.subheadline)
                    .bold()

                Text(errorDescription ?? "不明なエラー")
                    .font(.subheadline)
                    .bold()
            }

            Button {
                didTapReloadButton()
            } label: {
                Text("再読み込み")
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
