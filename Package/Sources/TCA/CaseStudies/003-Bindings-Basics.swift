import ComposableArchitecture
import SwiftUI

private let description = """
双方向バインディングを扱う方法を示しています。
SwiftUIの双方向バインディングは強力ですが、Composable Architectureの「一方向データフロー」とは異なります。これは、どのようなものでも、いつでも値を変更できるためです。

一方で、Composable Architectureでは、変更はストアへのアクションの送信によってのみ行われることが要求されます。これは、機能の状態がどのように変化するかを確認できる場所が、リデューサーであることを意味します。

Bindingを必要とする任意のSwiftUIコンポーネントは、Composable Architectureで使用できます。bindingメソッドを使用して、ViewStoreからBindingを導出することができます。これにより、コンポーネントを描画するための状態と、コンポーネントが変更されたときに送信するアクションを指定できます。これは、機能に一方向スタイルを維持することができることを意味します。
"""

// MARK: - Feature domain

@Reducer
struct BindingBasics {
    struct State: Equatable {
        var sliderValue = 5.0
        var stepCount = 10
        var text = ""
        var toggleIsOn = false
    }

    enum Action {
        case sliderValueChanged(Double)
        case stepCountChanged(Int)
        case textChanged(String)
        case toggleChanged(isOn: Bool)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .sliderValueChanged(value):
                state.sliderValue = value
                return .none

            case let .stepCountChanged(count):
                state.sliderValue = .minimum(state.sliderValue, Double(count))
                state.stepCount = count
                return .none

            case let .textChanged(text):
                state.text = text
                return .none

            case let .toggleChanged(isOn):
                state.toggleIsOn = isOn
                return .none
            }
        }
    }
}

// MARK: - Feature view

struct BindingBasicsView: View {
    @State private var store = Store(initialState: BindingBasics.State()) {
        BindingBasics()
    }

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section {
                    AboutView(description: description)
                }

                HStack {
                    TextField(
                        "Type here",
                        text: viewStore.binding(
                            get: \.text,
                            send: { .textChanged($0) }
                        )
                    )
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
                    isOn: viewStore.binding(
                        get: \.toggleIsOn,
                        send: { .toggleChanged(isOn: $0) }
                    )
                    .resignFirstResponder()
                )

                Stepper(
                    "Max slider value: \(viewStore.stepCount)",
                    value: viewStore.binding(
                        get: \.stepCount,
                        send: { .stepCountChanged($0) }
                    ),
                    in: 0 ... 100
                )
                .disabled(viewStore.toggleIsOn)

                HStack {
                    Text("Slider value: \(Int(viewStore.sliderValue))")
                    Slider(
                        value: viewStore.binding(
                            get: \.sliderValue,
                            send: { .sliderValueChanged($0) }
                        ),
                        in: 0 ... Double(viewStore.stepCount)
                    )
                    .tint(.accentColor)
                }
                .disabled(viewStore.toggleIsOn)
            }
        }
        .monospacedDigit()
        .navigationTitle("Bindings Basics")
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
        BindingBasicsView()
    }
}
