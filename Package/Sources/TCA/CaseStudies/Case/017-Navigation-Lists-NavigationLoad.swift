import ComposableArchitecture
import SwiftUI

private let description = """
リスト要素からオプショナルな状態をロードすることに依存するナビゲーションを示しています。

行をタップすると同時に、それに関連するカウンター状態に依存する画面にナビゲートし、1秒後にこの状態をロードするエフェクトを発火させます。
"""

// MARK: - Feature domain

@Reducer
struct NavigateAndLoadList {
    @Dependency(\.continuousClock) var clock

    struct State: Equatable {
        var rows: IdentifiedArrayOf<Row> = [
            Row(count: 1, id: UUID()),
            Row(count: 42, id: UUID()),
            Row(count: 100, id: UUID())
        ]

        var selection: Identified<Row.ID, Counter.State?>?

        struct Row: Equatable, Identifiable {
            var count: Int
            let id: UUID
        }
    }

    enum Action {
        case counter(Counter.Action)
        case setNavigation(selection: UUID?)
        case setNavigationSelectionDelayCompleted
    }

    private enum CancelID {
        case load
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .counter:
                return .none

            case let .setNavigation(selection: .some(id)):
                state.selection = Identified(nil, id: id)
                return .run { send in
                    try await clock.sleep(for: .seconds(1))
                    await send(.setNavigationSelectionDelayCompleted)
                }
                .cancellable(id: CancelID.load, cancelInFlight: true)

            case .setNavigation(selection: .none):
                if let selection = state.selection,
                   let count = selection.value?.count {
                    state.rows[id: selection.id]?.count = count
                }
                state.selection = nil
                return .cancel(id: CancelID.load)

            case .setNavigationSelectionDelayCompleted:
                guard let id = state.selection?.id else {
                    return .none
                }
                state.selection?.value = Counter.State(count: state.rows[id: id]?.count ?? 0)
                return .none
            }
        }
        .ifLet(\.selection, action: \.counter) {
            EmptyReducer()
                .ifLet(\.value, action: \.self) {
                    Counter()
                }
        }
    }
}

// MARK: - Feature view

struct NavigateAndLoadListView: View {
    @State private var store = Store(initialState: NavigateAndLoadList.State()) {
        NavigateAndLoadList()
    }

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section {
                    AboutView(description: description)
                }

                ForEach(viewStore.rows) { row in
                    NavigationLink(
                        "Load optional counter that starts from \(row.count)",
                        tag: row.id,
                        selection: viewStore.binding(
                            get: \.selection?.id,
                            send: { .setNavigation(selection: $0) }
                        )
                    ) {
                        IfLetStore(
                            store.scope(
                                state: \.selection?.value,
                                action: \.counter
                            )
                        ) {
                            CounterView(store: $0)
                        } else: {
                            ProgressView()
                        }
                    }
                }
            }
        }
        .navigationTitle("Navigate and load")
    }
}

#Preview {
    NavigationStack {
        NavigateAndLoadListView()
    }
}
