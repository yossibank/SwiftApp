import ComposableArchitecture
import SwiftUI

/// 基本的な操作
/// カウンターを増減させる機能実装

// MARK: - Feature domain

// Swift MacroでReducerの定義
@Reducer
struct CounterDescription {
    // State(状態を保持する構造体)の作成
    struct State: Equatable {
        // カウントの情報
        var count = 0
    }

    // Action(イベントやユーザー操作の表現)の作成
    enum Action {
        // カウントを増やすボタンを押した際のアクション
        case incrementButtonTapped
        // カウントを減らすボタンを押した際のアクション
        case decrementButtonTapped
    }

    // Reducerのbodyを作成し、Stateの状態を発火されたActionに応じて更新する
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .incrementButtonTapped:
                // Stateの更新(カウントを1増やす)
                state.count += 1
                // Effectを生成(副作用が発生しない場合はnoneを返す)
                return .none

            case .decrementButtonTapped:
                // Stateの更新(カウントを1減らす)
                state.count -= 1
                // Effectを生成(副作用が発生しない場合はnoneを返す)
                return .none
            }
        }
    }
}

// MARK: - Feature view

struct CounterDescriptionView: View {
    // Storeの定義
    let store: StoreOf<CounterDescription>

    var body: some View {
        // WithViewStoreを使用してStoreの状態をViewに適切に適合させる
        // 1. Viewへの状態の統合(ViewがStoreの状態の変更を監視し、状態が変更されるたびにUIを更新する)
        // 2. パフォーマンスの最適化(Viewが必要とする状態の部分だけに焦点を当てて、必要な状態の変更のみをViewの再描画のトリガーとする)
        // 3. ユーザーインタラクションのハンドリング(viewStore.send()でReducerにActionを送信する)
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack {
                Button {
                    viewStore.send(.decrementButtonTapped)
                } label: {
                    Image(systemName: "minus")
                }
            }

            Text("\(viewStore.count)")
                .monospacedDigit()

            Button {
                viewStore.send(.incrementButtonTapped)
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}

struct CounterDemoDescriptionView: View {
    @State private var store = Store(initialState: CounterDescription.State()) {
        CounterDescription()
    }

    var body: some View {
        Form {
            Section {
                CounterDescriptionView(store: store)
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.borderless)
        .navigationTitle("Counter Demo")
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CounterDescriptionView(
            store: Store(initialState: CounterDescription.State()) {
                CounterDescription()
            }
        )
    }
}
