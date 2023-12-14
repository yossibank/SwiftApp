import ComposableArchitecture
import SwiftUI

private let description = """
オプショナルなデータを状態にロードすることに依存するナビゲーションを示しています。

「Load optoinal counter」をタップすると、1秒後にカウンター状態をロードするエフェクトが発動します。

カウンター状態が存在する場合、このデータに依存するシートがプログラムによって表示されます。
"""

// MARK: - Feature domain

@Reducer
struct LoadThenPresent {
    @Dependency(\.continuousClock) var clock

    struct State: Equatable {
        @PresentationState var counter: Counter.State?
        var isActivityIndicatorVisible = false
    }

    enum Action {
        case counter(PresentationAction<Counter.Action>)
        case counterButtonTapped
        case counterPresentationDelayCompleted
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .counter:
                return .none

            case .counterButtonTapped:
                state.isActivityIndicatorVisible = true
                return .run { send in
                    try await clock.sleep(for: .seconds(1))
                    await send(.counterPresentationDelayCompleted)
                }

            case .counterPresentationDelayCompleted:
                state.isActivityIndicatorVisible = false
                state.counter = Counter.State()
                return .none
            }
        }
        .ifLet(\.$counter, action: \.counter) {
            Counter()
        }
    }
}

// MARK: - Feature view

struct LoadThenPresentView: View {
    @State private var store = Store(initialState: LoadThenPresent.State()) {
        LoadThenPresent()
    }

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section {
                    AboutView(description: description)
                }

                Button {
                    viewStore.send(.counterButtonTapped)
                } label: {
                    HStack {
                        Text("Load optoinal counter")

                        if viewStore.isActivityIndicatorVisible {
                            Spacer()
                            ProgressView()
                        }
                    }
                }
            }
            .sheet(
                store: store.scope(
                    state: \.$counter,
                    action: \.counter
                )
            ) {
                CounterView(store: $0)
            }
            .navigationTitle("Load and present")
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        LoadThenPresentView()
    }
}
