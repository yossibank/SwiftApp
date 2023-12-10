import ComposableArchitecture
import SwiftUI

private let description = """
Composable Architectureでアラートや確認ダイアログを最適に扱う方法を示しています。

ライブラリはアプリケーション内のすべてのデータフローが単一方向であることを要求しているため、状態をリデューサーを介さずに変更できるSwiftUIの双方向バインディングを利用することはできません。

これは、標準APIを直接使用してアラートやシートを表示することができないことを意味します。

しかし、ライブラリにはAlertStateとConfirmationDialogStateの2つのタイプがあり、これらはリデューサーから構築することができ、アラートや確認ダイアログが表示されるかどうかを制御できます。

さらに、ボタンをタップしたときにアクションを自動的に送信する機能も備えており、双方向バインディングやアクションクロージャーではなく、リデューサー内でその機能を適切に扱うことができます。

これを行う利点は、アプリケーション内でのユーザーのアラートやダイアログとのやり取りを完全にテストカバレッジすることができることです。
"""

// MARK: - Feature domain

@Reducer
struct AlertAndConfirmationDialog {
    struct State: Equatable {
        @PresentationState var alert: AlertState<Action.Alert>?
        @PresentationState var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDialog>?
        var count = 0
    }

    enum Action {
        case alert(PresentationAction<Alert>)
        case alertButtonTapped
        case confirmationDialog(PresentationAction<ConfirmationDialog>)
        case confirmationDialogButtonTapped

        enum Alert {
            case incrementButtonTapped
        }

        enum ConfirmationDialog {
            case incrementButtonTapped
            case decrementButtonTapped
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .alert(.presented(.incrementButtonTapped)),
                 .confirmationDialog(.presented(.incrementButtonTapped)):
                state.alert = AlertState { TextState("Incremented!") }
                state.count += 1
                return .none

            case .alert:
                return .none

            case .alertButtonTapped:
                state.alert = AlertState {
                    TextState("Alert!")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("Cancel")
                    }
                    ButtonState(action: .incrementButtonTapped) {
                        TextState("Increment")
                    }
                } message: {
                    TextState("This is an alert")
                }
                return .none

            case .confirmationDialog(.presented(.decrementButtonTapped)):
                state.alert = AlertState { TextState("Decremented!") }
                state.count -= 1
                return .none

            case .confirmationDialog:
                return .none

            case .confirmationDialogButtonTapped:
                state.confirmationDialog = ConfirmationDialogState {
                    TextState("Confirmation dialog")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("Cancel")
                    }
                    ButtonState(action: .incrementButtonTapped) {
                        TextState("Increment")
                    }
                    ButtonState(action: .decrementButtonTapped) {
                        TextState("Decrement")
                    }
                } message: {
                    TextState("This is a confirmation dialog")
                }
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
        .ifLet(\.$confirmationDialog, action: \.confirmationDialog)
    }
}

// MARK: - Feature view

struct AlertAndConfirmationDialogView: View {
    @State private var store = Store(initialState: AlertAndConfirmationDialog.State()) {
        AlertAndConfirmationDialog()
    }

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section {
                    AboutView(description: description)
                }

                Text("Count: \(viewStore.count)")
                Button("Alert") {
                    viewStore.send(.alertButtonTapped)
                }
                Button("Confirmation Dialog") {
                    viewStore.send(.confirmationDialogButtonTapped)
                }
            }
            .navigationTitle("Alerts & Confirmation Dialogs")
            .alert(
                store: store.scope(
                    state: \.$alert,
                    action: \.alert
                )
            )
            .confirmationDialog(
                store: store.scope(
                    state: \.$confirmationDialog,
                    action: \.confirmationDialog
                )
            )
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AlertAndConfirmationDialogView()
    }
}
