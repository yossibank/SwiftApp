import ComposableArchitecture
import SwiftUI

private let description = """
Composable Architectureでバインディング状態とアクションを使用して双方向バインディングを扱う方法を示しています。

バインディング状態とアクションを使用することで、各UIコントロールにユニークなアクションが必要となることによる定型文を安全に排除することができます。代わりに、すべてのUIバインディングは単一のbindingアクションに統合されることができ、そのアクションはBindingAction値を保持し、すべてのバインディング状態はBindingStateプロパティラッパーで保護されることができます。

「003-Bindings-Basics」と比較すれば違いが分かりやすいです。
"""

// MARK: - Feature domain

@Reducer
struct BindingForm {
    struct State: Equatable {
        @BindingState var sliderValue = 5.0
        @BindingState var stepCount = 10
        @BindingState var text = ""
        @BindingState var toggleIsOn = false
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case resetButtonTapped
    }

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding(\.$stepCount):
                state.sliderValue = .minimum(state.sliderValue, Double(state.stepCount))
                return .none

            case .binding:
                return .none

            case .resetButtonTapped:
                state = State()
                return .none
            }
        }
    }
}

// MARK: - Feature view

struct BindingFormView: View {
    @State private var store = Store(initialState: BindingForm.State()) {
        BindingForm()
    }

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section {
                    AboutView(description: description)
                }

                HStack {
                    TextField("Type here", text: viewStore.$text)
                        .autocorrectionDisabled()
                        .foregroundStyle(
                            viewStore.toggleIsOn
                                ? .secondary
                                : .primary
                        )
                    Text(alternate(viewStore.text))
                }
                .disabled(viewStore.toggleIsOn)

                Toggle(
                    "Disable other controls",
                    isOn: viewStore.$toggleIsOn.resignFirstResponder()
                )

                Stepper(
                    "Max slider value: \(viewStore.stepCount)",
                    value: viewStore.$stepCount,
                    in: 0 ... 100
                )
                .disabled(viewStore.toggleIsOn)

                HStack {
                    Text("Slider value: \(Int(viewStore.sliderValue))")

                    Slider(
                        value: viewStore.$sliderValue,
                        in: 0 ... Double(viewStore.stepCount)
                    )
                    .tint(.accentColor)
                }
                .disabled(viewStore.toggleIsOn)

                Button("Reset") {
                    viewStore.send(.resetButtonTapped)
                }
                .tint(.red)
            }
        }
        .monospacedDigit()
        .navigationTitle("Bindings Form")
    }
}

private func alternate(_ string: String) -> String {
    string
        .enumerated()
        .map { idx, char in
            idx.isMultiple(of: 2)
                ? char.uppercased()
                : char.lowercased()
        }
        .joined()
}

// MARK: - Preview

#Preview {
    NavigationStack {
        BindingFormView()
    }
}

// MARK: - Test

// import XCTest
//
// @MainActor
// final class BindingFormTests: XCTestCase {
//    func testBindingForm() async {
//        let store = TestStore(initialState: BindingForm.State()) {
//            BindingForm()
//        }
//
//        await store.send(.set(\.$sliderValue, 2)) {
//            $0.sliderValue = 2
//        }
//
//        await store.send(.set(\.$stepCount, 1)) {
//            $0.sliderValue = 1
//            $0.stepCount = 1
//        }
//
//        await store.send(.set(\.$text, "Blob")) {
//            $0.text = "Blob"
//        }
//
//        await store.send(.set(\.$toggleIsOn, true)) {
//            $0.toggleIsOn = true
//        }
//
//        await store.send(.resetButtonTapped) {
//            $0 = BindingForm.State(
//                sliderValue: 5,
//                stepCount: 10,
//                text: "",
//                toggleIsOn: false
//            )
//        }
//    }
// }
