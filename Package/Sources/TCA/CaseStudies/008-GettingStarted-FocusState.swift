import ComposableArchitecture
import SwiftUI

private let description = """
Composable ArchitectureでSwiftUIの`@FocusState`を使用する方法を示しています。

`bind`ビューモディファイアを使用することで、空のフィールドがある場合に「サインイン」ボタンをタップすると、そのフィールドにフォーカスが移動します。
"""

// MARK: - feature domain

@Reducer
struct FocusDemo {
    struct State: Equatable {
        @BindingState var focusedField: Field?
        @BindingState var username = ""
        @BindingState var password = ""

        enum Field: String, Hashable {
            case username
            case password
        }
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case signInButtonTapped
    }

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .signInButtonTapped:
                if state.username.isEmpty {
                    state.focusedField = .username
                } else if state.password.isEmpty {
                    state.focusedField = .password
                }
                return .none
            }
        }
    }
}

// MARK: -  Feature view

struct FocusDemoView: View {
    @State private var store = Store(initialState: FocusDemo.State()) {
        FocusDemo()
    }

    @FocusState private var focusedField: FocusDemo.State.Field?

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                AboutView(description: description)

                VStack {
                    TextField("Username", text: viewStore.$username)
                        .focused($focusedField, equals: .username)
                    SecureField("Password", text: viewStore.$password)
                        .focused($focusedField, equals: .password)
                    Button("Sign In") {
                        viewStore.send(.signInButtonTapped)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .textFieldStyle(.roundedBorder)
            }
            // ストアのフォーカス状態とローカルのフォーカス状態を同期します。
            .bind(viewStore.$focusedField, to: $focusedField)
        }
        .navigationTitle("Focus Demo")
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        FocusDemoView()
    }
}
