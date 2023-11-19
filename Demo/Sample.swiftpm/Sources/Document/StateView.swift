import SwiftUI

struct StateView: View {
    @State private var isPlaying = false

    var body: some View {
        VStack(spacing: 32) {
            Button(isPlaying ? "Pause" : "Play") {
                isPlaying.toggle()
            }

            BindingView(isPlaying: $isPlaying)
        }
    }
}

#Preview {
    StateView()
}
