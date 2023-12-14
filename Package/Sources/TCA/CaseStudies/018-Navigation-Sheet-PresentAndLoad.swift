import ComposableArchitecture
import SwiftUI

private let description = """
オプショナルなデータを状態にロードすることに依存するナビゲーションを示しています。

「Load optional counter」をタップすると、オプショナルなカウンター状態に依存するシートが同時に表示され、1秒後にこの状態をロードするエフェクトが発動します。
"""

// MARK: - Feature domain

@Reducer
struct PresentAndLoad {
    @Dependency(\.continuousClock) var clock

    struct State: Equatable {
        var optionalCounter: Counter.State?
        var isSheetPresented = false
    }

    enum Action {
        case optionalCounter(Counter.Action)
        case setSheet(isPresented: Bool)
        case setSheetIsPresentedDelayCompleted
    }

    private enum CancelID {
        case load
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .optionalCounter:
                return .none

            case .setSheet(isPresented: true):
                state.isSheetPresented = true
                return .run { send in
                    try await clock.sleep(for: .seconds(1))
                    await send(.setSheetIsPresentedDelayCompleted)
                }

            case .setSheet(isPresented: false):
                state.isSheetPresented = false
                state.optionalCounter = nil
                return .cancel(id: CancelID.load)

            case .setSheetIsPresentedDelayCompleted:
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

struct PresentAndLoadView: View {
    @State private var store = Store(initialState: PresentAndLoad.State()) {
        PresentAndLoad()
    }

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section {
                    AboutView(description: description)
                }

                Button("Load optional counter") {
                    viewStore.send(.setSheet(isPresented: true))
                }
            }
            .sheet(
                isPresented: viewStore.binding(
                    get: \.isSheetPresented,
                    send: { .setSheet(isPresented: $0) }
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
            .navigationTitle("Present and load")
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PresentAndLoadView()
    }
}
