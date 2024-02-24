import SwiftUI

struct FloatingActionButtonView: View {
    @Binding var isSelected: Bool

    let actionButtons: [FloatingActionButton]

    var body: some View {
        VStack(spacing: 16) {
            if isSelected {
                ForEach(actionButtons) { actionButton in
                    Button {
                        withAnimation(.easeIn(duration: 0.3)) {
                            isSelected.toggle()
                        }
                        actionButton.didTap()
                    } label: {
                        Image(systemName: actionButton.iconName)
                            .resizable()
                            .frame(width: 25, height: 25)
                    }
                    .frame(width: 60, height: 60)
                    .background(Color.green)
                    .foregroundStyle(.white)
                    .clipShape(Circle())
                    .transition(.move(edge: .bottom))
                }
            }

            Button {
                withAnimation(.easeIn(duration: 0.3)) {
                    isSelected.toggle()
                }
            } label: {
                Image(systemName: "plus")
                    .resizable()
                    .frame(width: 25, height: 25)
            }
            .frame(width: 60, height: 60)
            .background(Color.accentColor)
            .foregroundStyle(.white)
            .clipShape(Circle())
            .rotationEffect(.init(degrees: isSelected ? 45 : 0))
        }
    }
}

struct FloatingActionButton: Identifiable {
    let id = UUID().uuidString
    let iconName: String
    let didTap: () -> Void
}

#Preview {
    FloatingActionButtonView(
        isSelected: .constant(true),
        actionButtons: [
            .init(iconName: "magnifyingglass", didTap: {}),
            .init(iconName: "plus", didTap: {})
        ]
    )
}
