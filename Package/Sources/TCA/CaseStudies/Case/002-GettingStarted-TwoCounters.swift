import ComposableArchitecture
import SwiftUI

private let description = """
この画面は、Reducerビルダーと Scopeリデューサーを使用して、小さな機能をより大きな機能に組み合わせる方法、およびストア上のscopeオペレーターの使用方法を示しています。

これはカウンター画面のドメインを再利用し、それをより大きなドメインに二度埋め込んでいます。
"""

// MARK: - Feature domain

@Reducer
struct TwoCounters {
    struct State: Equatable {
        var counter1 = Counter.State()
        var counter2 = Counter.State()
    }

    enum Action {
        case counter1(Counter.Action)
        case counter2(Counter.Action)
    }

    var body: some Reducer<State, Action> {
        // ScopeでStoreから更新するものを指定する
        // 範囲指定することでStoreの特定のものを変更した時のみViewを再描画させるようにする
        Scope(state: \.counter1, action: \.counter1) {
            Counter()
        }
        Scope(state: \.counter2, action: \.counter2) {
            Counter()
        }
    }
}

// MARK: - Feature view

struct TwoCountersView: View {
    @State private var store = Store(initialState: TwoCounters.State()) {
        TwoCounters()
    }

    var body: some View {
        Form {
            Section {
                AboutView(description: description)
            }

            HStack {
                Text("Counter 1")
                Spacer()
                CounterView(
                    store: store.scope(
                        state: \.counter1,
                        action: \.counter1
                    )
                )
            }

            HStack {
                Text("Counter 2")
                Spacer()
                CounterView(
                    store: store.scope(
                        state: \.counter2,
                        action: \.counter2
                    )
                )
            }
        }
        .buttonStyle(.borderless)
        .navigationTitle("TwoCounters Demo")
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        TwoCountersView()
    }
}
