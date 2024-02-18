import SwiftUI

struct CenterView<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack {
            Spacer()
            content()
            Spacer()
        }
    }
}
