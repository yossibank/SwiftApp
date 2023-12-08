import ComposableArchitecture
import SwiftUI

private let description1 = """
複数の独立した画面がComposable Architectureでどのように状態を共有するかを示しています。各タブは独自の状態を管理し、別々のモジュールにある可能性がありますが、一つのタブでの変更は他のタブに即座に反映されます。

このタブには独自の状態があり、カウント値の増減や、現在のカウントが素数であるかどうかを尋ねる際に設定されるアラート値が含まれています。

内部的には、最小および最大カウント数や、発生したカウントイベントの総数など、さまざまな統計も追跡しています。これらの状態は他のタブで表示でき、統計は他のタブからリセットできます。
"""

private let description2 = """
このタブは前のタブからの状態を表示し、すべての状態を0にリセットすることができます。

これは、各画面がそれぞれに最も適した方法で状態をモデル化しながらも、状態と変更を独立した画面間で共有することが可能であることを示しています。
"""

// MARK: - Feature domain

@Reducer
struct SharedState {
    enum Tab {
        case counter
        case profile
    }

    struct State: Equatable {
        var counter = Counter.State()
        var currentTab = Tab.counter

        /// Profile.StateはCounter.Stateから関連する部分を取得して導出する
        /// プロフィール機能はアプリの全状態ではなく、アプリ状態のサブセット上で動作することが可能になる
        var profile: Profile.State {
            get {
                Profile.State(
                    currentTab: currentTab,
                    count: counter.count,
                    maxCount: counter.maxCount,
                    minCount: counter.minCount,
                    numberOfCounts: counter.numberOfCounts
                )
            }
            set {
                currentTab = newValue.currentTab
                counter.count = newValue.count
                counter.maxCount = newValue.maxCount
                counter.minCount = newValue.minCount
                counter.numberOfCounts = newValue.numberOfCounts
            }
        }
    }

    enum Action {
        case counter(Counter.Action)
        case profile(Profile.Action)
        case selectTab(Tab)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.counter, action: \.counter) {
            Counter()
        }

        Scope(state: \.profile, action: \.profile) {
            Profile()
        }

        Reduce { state, action in
            switch action {
            case .counter, .profile:
                return .none

            case let .selectTab(tab):
                state.currentTab = tab
                return .none
            }
        }
    }

    @Reducer
    struct Counter {
        struct State: Equatable {
            @PresentationState var alert: AlertState<Action.Alert>?
            var count = 0
            var maxCount = 0
            var minCount = 0
            var numberOfCounts = 0
        }

        enum Action {
            case alert(PresentationAction<Alert>)
            case decrementButtonTapped
            case incrementButtonTapped
            case isPrimeButtonTapped

            enum Alert: Equatable {}
        }

        var body: some Reducer<State, Action> {
            Reduce { state, action in
                switch action {
                case .alert:
                    return .none

                case .decrementButtonTapped:
                    state.count -= 1
                    state.numberOfCounts += 1
                    state.minCount = min(state.minCount, state.count)
                    return .none

                case .incrementButtonTapped:
                    state.count += 1
                    state.numberOfCounts += 1
                    state.maxCount = max(state.maxCount, state.count)
                    return .none

                case .isPrimeButtonTapped:
                    state.alert = AlertState {
                        TextState(
                            isPrime(state.count)
                            ? "👍 The number \(state.count) is prime!"
                            : "👎 The number \(state.count) is not prime :("
                        )
                    }
                    return .none
                }
            }
            .ifLet(\.$alert, action: \.alert)
        }
    }

    @Reducer
    struct Profile {
        struct State: Equatable {
            private(set) var currentTab: Tab
            private(set) var count = 0
            private(set) var maxCount: Int
            private(set) var minCount: Int
            private(set) var numberOfCounts: Int

            fileprivate mutating func resetCount() {
                currentTab = .counter
                count = 0
                maxCount = 0
                minCount = 0
                numberOfCounts = 0
            }
        }

        enum Action {
            case resetCounterButtonTapped
        }

        var body: some Reducer<State, Action> {
            Reduce { state, action in
                switch action {
                case .resetCounterButtonTapped:
                    state.resetCount()
                    return .none
                }
            }
        }
    }
}

// MARK: - Feature view

struct SharedStateView: View {
    @State private var store = Store(initialState: SharedState.State()) {
        SharedState()
    }

    var body: some View {
        WithViewStore(store, observe: \.currentTab) { viewStore in
            VStack {
                Picker(
                    "Tab",
                    selection: viewStore.binding(send: { .selectTab($0) })
                ) {
                    Text("Counter")
                        .tag(SharedState.Tab.counter)
                    Text("Profile")
                        .tag(SharedState.Tab.profile)
                }
                .pickerStyle(.segmented)

                if viewStore.state == .counter {
                    SharedStateCounterView(
                        store: store.scope(
                            state: \.counter,
                            action: \.counter
                        )
                    )
                }

                if viewStore.state == .profile {
                    SharedStateProfileView(
                        store: store.scope(
                            state: \.profile,
                            action: \.profile
                        )
                    )
                }

                Spacer()
            }
        }
        .padding()
    }
}

struct SharedStateCounterView: View {
    let store: StoreOf<SharedState.Counter>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 64) {
                Text(description1)
                    .font(.caption)

                VStack(spacing: 16) {
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

                    Button("Is this prime?") {
                        viewStore.send(.isPrimeButtonTapped)
                    }
                }
            }
            .padding(.top)
            .navigationTitle("Shaerd State Demo")
            .alert(
                store: store.scope(
                    state: \.$alert,
                    action: \.alert
                )
            )
        }
    }
}

struct SharedStateProfileView: View {
    let store: StoreOf<SharedState.Profile>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 64) {
                Text(description2)
                    .font(.caption)

                VStack(spacing: 16) {
                    Text("Current count: \(viewStore.count)")
                    Text("Max count: \(viewStore.maxCount)")
                    Text("Min count: \(viewStore.minCount)")
                    Text("Total number of count events: \(viewStore.numberOfCounts)")
                    Button("Reset") {
                        viewStore.send(.resetCounterButtonTapped)
                    }
                }
            }
            .padding(.top)
            .navigationTitle("Profile")
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SharedStateView()
    }
}

// MARK: - Private helpers

private func isPrime(_ p: Int) -> Bool {
    if p <= 1 { return false }
    if p <= 3 { return true }

    // 平方根出力
    for i in 2 ... Int(sqrtf(Float(p))) {
        if p % i == 0 { return false }
    }

    return true
}
