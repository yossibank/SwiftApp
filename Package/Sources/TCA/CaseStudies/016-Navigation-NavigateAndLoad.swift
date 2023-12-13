import ComposableArchitecture
import SwiftUI

private let description = """
オプショナルな状態のロードに依存するナビゲーションを示しています。

「Load optional counter」をタップすると、オプショナルなカウンター状態に依存する画面に同時にナビゲートし、1秒後にこの状態をロードするエフェクトが発動します。
"""

// MARK: - Feature domain

@Reducer
struct NavigateAndLoad {
    @Dependency(\.continuousClock) var clock

    struct State: Equatable {
        var isNavigationActive = false
        var optionalCounter: Counter.State?
    }

    enum Action {
        case optionalCounter(Counter.Action)
        case setNavigation(isActive: Bool)
        case setNavigationIsActiveDelayCompleted
    }

    private enum CancelID {
        case load
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .optionalCounter:
                return .none

            case .setNavigation(isActive: true):
                state.isNavigationActive = true
                return .run { send in
                    try await clock.sleep(for: .seconds(1))
                    await send(.setNavigationIsActiveDelayCompleted)
                }
                .cancellable(id: CancelID.load)

            case .setNavigation(isActive: false):
                state.isNavigationActive = false
                state.optionalCounter = nil
                return .cancel(id: CancelID.load)

            case .setNavigationIsActiveDelayCompleted:
                state.optionalCounter = Counter.State()
                return .none
            }
        }
        .ifLet(\.optionalCounter, action: \.optionalCounter) {
            Counter()
        }
    }
}

// MARK: - Feature view

struct NavigateAndLoadView: View {
    @State private var store = Store(initialState: NavigateAndLoad.State()) {
        NavigateAndLoad()
    }

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section {
                    AboutView(description: description)
                }

                NavigationLink(
                    "Load optional counter",
                    isActive: viewStore.binding(
                        get: \.isNavigationActive,
                        send: { .setNavigation(isActive: $0) }
                    )
                ) {
                    IfLetStore(
                        store.scope(
                            state: \.optionalCounter,
                            action: \.optionalCounter
                        )
                    ) {
                        CounterView(store: $0)
                    } else: {
                        ProgressView()
                    }
                }
            }
        }
        .navigationTitle("Navigate and load")
    }
}
