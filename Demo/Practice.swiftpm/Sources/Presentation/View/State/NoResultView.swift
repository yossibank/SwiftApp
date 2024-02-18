import SwiftUI

struct NoResultView: View {
    let title: String

    var body: some View {
        VStack(spacing: 24) {
            Image("information", bundle: .module)
                .resizable()
                .frame(width: 80, height: 80)

            Text(title)
                .font(.headline)
                .font(.subheadline)
                .bold()
        }
    }
}

#Preview {
    NoResultView(title: "該当する商品が見つかりませんでした")
}

