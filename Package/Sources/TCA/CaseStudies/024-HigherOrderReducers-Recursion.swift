import ComposableArchitecture
import SwiftUI

private let description = """
`Reducer`のbodyがどのようにして自分自身を再帰的にネストすることができるかを示しています。

「行を追加」をタップして、現在の画面のリストに行を追加します。

行の左側をタップして名前を編集するか、行の右側をタップしてその行に関連付けられた独自の行リストにナビゲートします。
"""

// MARK: - Feature domain

@Reducer
struct Nested {
    @Dependency(\.uuid) var uuid

    struct State: Equatable, Identifiable {
        let id: UUID
        var name = ""
        var rows: IdentifiedArrayOf<State> = []
    }

    enum Action {
        case addRowButtonTapped
        case nameTextFieldChanged(String)
        case onDelete(IndexSet)
        indirect case rows(IdentifiedActionOf<Nested>)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .addRowButtonTapped:
                state.rows.append(State(id: uuid()))
                return .none

            case let .nameTextFieldChanged(name):
                state.name = name
                return .none

            case let .onDelete(indexSet):
                state.rows.remove(atOffsets: indexSet)
                return .none

            case .rows:
                return .none
            }
        }
        .forEach(\.rows, action: \.rows) {
            Self()
        }
    }
}

// MARK: - Feature view

struct NestedView: View {
    @State var store = Store(initialState: Nested.State(id: UUID())) {
        Nested()
    }

    var body: some View {
        WithViewStore(store, observe: \.name) { viewStore in
            Form {
                Section {
                    AboutView(description: description)
                }

                ForEachStore(
                    store.scope(
                        state: \.rows,
                        action: \.rows
                    )
                ) { rowStore in
                    WithViewStore(rowStore, observe: \.name) { rowViewStore in
                        NavigationLink(destination: NestedView(store: rowStore)) {
                            HStack {
                                TextField(
                                    "Untitled",
                                    text: rowViewStore.binding(send: { .nameTextFieldChanged($0) })
                                )
                                Text("Next")
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .onDelete {
                    viewStore.send(.onDelete($0))
                }
            }
            .navigationTitle(viewStore.state.isEmpty ? "Untitled" : viewStore.state)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add row") {
                        viewStore.send(.addRowButtonTapped)
                    }
                }
            }
        }
    }
}
