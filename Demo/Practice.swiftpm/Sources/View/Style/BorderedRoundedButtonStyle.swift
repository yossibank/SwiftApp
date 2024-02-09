import SwiftUI

struct BorderedRoundedButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .fontWeight(.bold)
            .foregroundStyle(.red)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.red, lineWidth: 2)
            )
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? .pink.opacity(0.3) : .white)
            )
            .opacity(configuration.isPressed ? 0.5 : 1.0)
    }
}
