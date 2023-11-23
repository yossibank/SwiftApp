import SwiftUI

struct BindingView: View {
    @Binding var isPlaying: Bool

    var body: some View {
        Toggle(
            isOn: $isPlaying,
            label: {
                Text(isPlaying ? "ON" : "OFF")
            }
        )
        .frame(width: 100)
    }
}

#Preview("all status") {
    VStack {
        ForEach([true, false], id: \.self) {
            BindingView(isPlaying: .constant($0))
        }
    }
}
