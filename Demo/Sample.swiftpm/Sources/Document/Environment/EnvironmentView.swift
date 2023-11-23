import SwiftUI

struct EnvironmentView: View {
    @State private var isShowModal = false

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 16) {
            Text(colorScheme == .light ? "light" : "dark")

            Button("Modal") {
                isShowModal.toggle()
            }
        }
        .sheet(isPresented: $isShowModal) {
            ModalView()
        }
    }
}

private struct ModalView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text("Modal View")

            Button("Close") {
                dismiss()
            }
        }
    }
}

#Preview {
    EnvironmentView()
}
