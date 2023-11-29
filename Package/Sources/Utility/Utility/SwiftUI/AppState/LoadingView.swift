import SwiftUI

public struct LoadingView: View {
    @State private var isAnimating = false

    public init() {}

    public var body: some View {
        Circle()
            .stroke(.gray.opacity(0.1), lineWidth: 5)
            .overlay {
                Circle()
                    .trim(from: 0, to: 0.5)
                    .stroke(.gray, style: .init(lineWidth: 5, lineCap: .round))
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(
                        .linear(duration: 1).repeatForever(autoreverses: false),
                        value: isAnimating
                    )
                    .onAppear {
                        isAnimating = true
                    }
            }
            .frame(width: 50, height: 50)
    }
}

#Preview {
    LoadingView()
}
