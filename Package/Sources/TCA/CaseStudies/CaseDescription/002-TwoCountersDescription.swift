import ComposableArchitecture
import SwiftUI

/// 基本的な操作
/// カウンターを増減させる機能実装
/// Reducer内で別のReducerのStateを個別に持ち、個々の状態を保持できるようにする

// MARK: - Feature domain

@Reducer
struct TwoCountersDescription {
    struct State: Equatable {
        // CounterのStateの状態を保持する
        var counter1 = CounterDescription.State()
        var counter2 = CounterDescription.State()
    }

    enum Action {
        // Reducerに送信するためのアクションを定義してStateを変更できるようにする
        case counter1(CounterDescription.Action)
        case counter2(CounterDescription.Action)
    }

    var body: some Reducer<State, Action> {
        // 親のReducerの一部分に子のReducerを適用させる
        // Stateのcounter1、Actionのcounter1(Counter.Action)に対してCounterのReducerを生成
        Scope(state: \.counter1, action: \.counter1) {
            CounterDescription()
        }
        // Stateのcounter2、Actionのcounter2(Counter.Action)に対してCounterのReducerを生成
        Scope(state: \.counter2, action: \.counter2) {
            CounterDescription()
        }
    }
}

// MARK: - Feature view

struct TwoCountersDescriptionView: View {
    @State private var store = Store(initialState: TwoCountersDescription.State()) {
        TwoCountersDescription()
    }

    var body: some View {
        Form {
            HStack {
                Text("Counter1")
                Spacer()
                // storeをscopeで渡して状態を個別管理できるようにする
                CounterDescriptionView(
                    store: store.scope(
                        state: \.counter1,
                        action: \.counter1
                    )
                )
            }

            HStack {
                Text("Counter2")
                Spacer()
                // storeをscopeで渡して状態を個別管理できるようにする
                CounterDescriptionView(
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
        TwoCountersDescriptionView()
    }
}
