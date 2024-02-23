import SwiftUI

struct ToastView: View {
    @Binding var isShown: Bool

    var toastType: ToastType
    var message: String?

    var body: some View {
        HStack(spacing: 16) {
            toastType.iconImage
                .resizable()
                .scaledToFit()
                .frame(height: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(toastType.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(toastType.foregroundColor)

                if let message {
                    Text(message)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(toastType.foregroundColor)
                }
            }
        }
        .padding(12)
        .background(toastType.backgroundStyle)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture {
            withAnimation {
                isShown = false
            }
        }
        .onAppear {
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(3))

                withAnimation {
                    isShown = false
                }
            }
        }
    }
}

#Preview {
    ToastView(
        isShown: .constant(true),
        toastType: .done,
        message: "タスクが終わりました"
    )
}
