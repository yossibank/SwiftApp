import ComposableArchitecture
import SwiftUI

private let description = """
この画面は、典型的なカウンターアプリケーションにおけるComposableArchitectureの基本を示しています。
アプリケーションのドメインは、アプリケーションの可変状態やその状態、または外部世界に影響を与える可能性のあるアクションに対応する単純なデータ型を使用してモデル化されています。
"""

// MARK: - Feature domain

@Reducer
struct Counter {
    struct State: Equatable {
        var count = 0
    }

    enum Action {
        case decrementButtonTapped
        case incrementButtonTapped
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .decrementButtonTapped:
                state.count -= 1
                // Effectを返す、何かしらの外部影響が発生するか
                return .none

            case .incrementButtonTapped:
                state.count += 1
                // Effectを返す、何かしらの外部影響が発生するか
                return .none
            }
        }
    }
}

// MARK: - Feature view

struct CounterView: View {
    let store: StoreOf<Counter>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack {
                Button {
                    viewStore.send(.decrementButtonTapped)
                } label: {
                    Image(systemName: "minus")
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
}

struct CounterDemoView: View {
    @State private var store = Store(initialState: Counter.State()) {
        Counter()
    }

    var body: some View {
        Form {
            Section {
                AboutView(description: description)
            }

            Section {
                CounterView(store: store)
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
        CounterDemoView()
    }
}

// MARK: - Test

// import XCTest
//
// @MainActor
// final class CounterTests: XCTestCase {
//    func testCount() async {
//        let store = TestStore(initialState: Counter.State()) {
//            Counter()
//        }
//
//        await store.send(.incrementButtonTapped) {
//            $0.count = 1
//        }
//
//        await store.send(.decrementButtonTapped) {
//            $0.count = 0
//        }
//
//        await store.send(.decrementButtonTapped) {
//            $0.count = -1
//        }
//    }
// }
