import ComposableArchitecture
import SwiftUI

private let description = """
オプショナルな子の状態の有無に基づいてビューを表示および非表示にする方法を示しています。

親の状態はCounter.State?値を保持しています。これが nil の場合、デフォルトでプレーンテキストビューになります。しかし、nil でない場合は、オプショナルでないカウンター状態に対応するカウンターのビューフラグメントを表示します。

「Toggle counter state」をタップすると、nilと非nilのカウンター状態の間で切り替わります。
"""

// MARK: - Feature domain

@Reducer
struct OptionalBasics {
    struct State: Equatable {
        var optionalCounter: Counter.State?
    }

    enum Action {
        case optionalCounter(Counter.Action)
        case toggleCounterButtonTapped
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .optionalCounter:
                return .none

            case .toggleCounterButtonTapped:
                state.optionalCounter = state.optionalCounter == nil
                    ? Counter.State()
                    : nil

                return .none
            }
        }
        .ifLet(\.optionalCounter, action: \.optionalCounter) {
            Counter()
        }
    }
}

// MARK: - Feature view

struct OptionalBasicsView: View {
    @State var store = Store(initialState: OptionalBasics.State()) {
        OptionalBasics()
    }

    var body: some View {
        Form {
            Section {
                AboutView(description: description)
            }

            Button("Toggle counter state") {
                store.send(.toggleCounterButtonTapped)
            }

            IfLetStore(
                store.scope(
                    state: \.optionalCounter,
                    action: \.optionalCounter
                )
            ) { store in
                Text("`Counter.State` is non-`nil`")
                CounterView(store: store)
                    .buttonStyle(.borderless)
                    .frame(maxWidth: .infinity)
            } else: {
                Text("`Counter.State` is `nil`")
            }
        }
        .navigationTitle("Optional State")
    }
}

// MARK: - Preview

#Preview {
    Group {
        NavigationStack {
            OptionalBasicsView()
        }

        NavigationStack {
            OptionalBasicsView(
                store: Store(initialState: OptionalBasics.State(optionalCounter: Counter.State(count: 42))) {
                    OptionalBasics()
                }
            )
        }
    }
}
