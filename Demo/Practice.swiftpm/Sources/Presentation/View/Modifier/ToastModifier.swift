import SwiftUI

struct ToastModifier: ViewModifier {
    @Binding var isShown: Bool

    var toastType: ToastType
    var message: String?

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content

            if isShown {
                ToastView(
                    isShown: _isShown,
                    toastType: toastType,
                    message: message
                )
                .frame(maxWidth: .infinity)
            }
        }
    }
}

enum ToastType {
    case done
    case warning
    case error

    var title: String {
        switch self {
        case .done:
            "完了"

        case .warning:
            "警告"

        case .error:
            "エラー"
        }
    }

    var foregroundColor: Color {
        switch self {
        case .error, .done:
            .white

        case .warning:
            .white
        }
    }

    var backgroundStyle: some ShapeStyle {
        switch self {
        case .done:
            Color.green.opacity(0.8)

        case .warning:
            Color.yellow.opacity(0.8)

        case .error:
            Color.red.opacity(0.8)
        }
    }

    var iconImage: Image {
        switch self {
        case .done:
            Image("done", bundle: .module)

        case .warning:
            Image("warning", bundle: .module)

        case .error:
            Image("error", bundle: .module)
        }
    }
}
