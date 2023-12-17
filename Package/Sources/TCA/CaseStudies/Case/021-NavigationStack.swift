import ComposableArchitecture
import SwiftUI

private let description = """
Composable Architectureアプリケーションで`NavigationStack`を使用する方法を示しています。
"""

// MARK: - Feature domain

@Reducer
struct NavigationDemo {
    struct State: Equatable {
        var path = StackState<Path.State>()
    }

    enum Action {
        case goBackToScreen(id: StackElementID)
        case goToABCButtonTapped
        case path(StackAction<Path.State, Path.Action>)
        case popToRoot
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .goBackToScreen(id):
                state.path.pop(to: id)
                return .none

            case .goToABCButtonTapped:
                state.path.append(.screenA())
                state.path.append(.screenB())
                state.path.append(.screenC())
                return .none

            case let .path(action):
                switch action {
                case .element(id: _, action: .screenB(.screenAButtonTapped)):
                    state.path.append(.screenA())
                    return .none

                case .element(id: _, action: .screenB(.screenBButtonTapped)):
                    state.path.append(.screenB())
                    return .none

                case .element(id: _, action: .screenB(.screenCButtonTapped)):
                    state.path.append(.screenC())
                    return .none

                default:
                    return .none
                }

            case .popToRoot:
                state.path.removeAll()
                return .none
            }
        }
        .forEach(\.path, action: \.path) {
            Path()
        }
    }

    @Reducer
    struct Path {
        enum State: Codable, Equatable, Hashable {
            case screenA(ScreenA.State = .init())
            case screenB(ScreenB.State = .init())
            case screenC(ScreenC.State = .init())
        }

        enum Action {
            case screenA(ScreenA.Action)
            case screenB(ScreenB.Action)
            case screenC(ScreenC.Action)
        }

        var body: some Reducer<State, Action> {
            Scope(state: \.screenA, action: \.screenA) {
                ScreenA()
            }
            Scope(state: \.screenB, action: \.screenB) {
                ScreenB()
            }
            Scope(state: \.screenC, action: \.screenC) {
                ScreenC()
            }
        }
    }
}

// MARK: - Feature view

struct NavigationDemoView: View {
    @State private var store = Store(initialState: NavigationDemo.State()) {
        NavigationDemo()
    }

    var body: some View {
        NavigationStackStore(
            store.scope(
                state: \.path,
                action: \.path
            )
        ) {
            Form {
                Section {
                    AboutView(description: description)
                }

                Section {
                    NavigationLink(
                        "Go to Screen A",
                        state: NavigationDemo.Path.State.screenA()
                    )

                    NavigationLink(
                        "Go to Screen B",
                        state: NavigationDemo.Path.State.screenB()
                    )

                    NavigationLink(
                        "Go to Screen C",
                        state: NavigationDemo.Path.State.screenC()
                    )
                }

                Section {
                    Button("Go to A → B → C") {
                        store.send(.goToABCButtonTapped)
                    }
                }
            }
            .navigationTitle("Root")
        } destination: {
            switch $0 {
            case .screenA:
                CaseLet(
                    \NavigationDemo.Path.State.screenA,
                    action: NavigationDemo.Path.Action.screenA,
                    then: ScreenAView.init(store:)
                )

            case .screenB:
                CaseLet(
                    \NavigationDemo.Path.State.screenB,
                    action: NavigationDemo.Path.Action.screenB,
                    then: ScreenBView.init(store:)
                )

            case .screenC:
                CaseLet(
                    \NavigationDemo.Path.State.screenC,
                    action: NavigationDemo.Path.Action.screenC,
                    then: ScreenCView.init(store:)
                )
            }
        }
        .safeAreaInset(edge: .bottom) {
            FloatingMenuView(store: store)
        }
        .navigationTitle("Navigation Stack")
    }
}

// MARK: - Floating menu

struct FloatingMenuView: View {
    let store: StoreOf<NavigationDemo>

    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            if viewStore.currentStack.count > 0 {
                VStack {
                    Text("Total count: \(viewStore.total)")

                    Button("Pop to root") {
                        viewStore.send(
                            .popToRoot,
                            animation: .default
                        )
                    }

                    Menu("Current stack") {
                        ForEach(viewStore.currentStack) { screen in
                            Button("\(String(describing: screen.id)) \(screen.name)") {
                                viewStore.send(.goBackToScreen(id: screen.id))
                            }
                            .disabled(screen == viewStore.currentStack.first)
                        }

                        Button("Root") {
                            viewStore.send(
                                .popToRoot,
                                animation: .default
                            )
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .padding(.bottom, 1)
                .transition(.opacity.animation(.default))
                .clipped()
                .shadow(color: .black.opacity(0.2), radius: 5, y: 5)
            }
        }
    }

    struct ViewState: Equatable {
        struct Screen: Equatable, Identifiable {
            let id: StackElementID
            let name: String
        }

        var currentStack: [Screen]
        var total: Int

        init(state: NavigationDemo.State) {
            self.total = 0
            self.currentStack = []

            for (id, element) in zip(state.path.ids, state.path) {
                switch element {
                case let .screenA(screenAState):
                    total += screenAState.count
                    currentStack.insert(
                        Screen(id: id, name: "Screen A"),
                        at: 0
                    )

                case .screenB:
                    currentStack.insert(
                        Screen(id: id, name: "Screen B"),
                        at: 0
                    )

                case let .screenC(screenCState):
                    total += screenCState.count
                    currentStack.insert(
                        Screen(id: id, name: "Screen C"),
                        at: 0
                    )
                }
            }
        }
    }
}

// MARK: - Screen A

@Reducer
struct ScreenA {
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.factClient) var factClient

    struct State: Codable, Equatable, Hashable {
        var count = 0
        var fact: String?
        var isLoading = false
    }

    enum Action {
        case decrementButtonTapped
        case dismissButtonTapped
        case incrementButtonTapped
        case factButtonTapped
        case factResposne(Result<String, Error>)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .decrementButtonTapped:
                state.count -= 1
                return .none

            case .dismissButtonTapped:
                return .run { _ in
                    await dismiss()
                }

            case .incrementButtonTapped:
                state.count += 1
                return .none

            case .factButtonTapped:
                state.isLoading = true
                return .run { [count = state.count] send in
                    await send(.factResposne(Result {
                        try await factClient.fetch(count)
                    }))
                }

            case let .factResposne(.success(fact)):
                state.isLoading = false
                state.fact = fact
                return .none

            case .factResposne(.failure):
                state.isLoading = false
                state.fact = nil
                return .none
            }
        }
    }
}

struct ScreenAView: View {
    let store: StoreOf<ScreenA>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Text(
                    """
                    ナビゲーションスタック内にホストされた基本機能を示しています。

                    子機能が自らを閉じることもでき、これによりルートスタックビューに通知され、機能がスタックからポップオフされます。
                    """
                )

                Section {
                    HStack {
                        Text("\(viewStore.count)")
                        Spacer()
                        Button {
                            viewStore.send(.decrementButtonTapped)
                        } label: {
                            Image(systemName: "minus")
                        }
                        Button {
                            viewStore.send(.incrementButtonTapped)
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                    .buttonStyle(.borderless)

                    Button {
                        viewStore.send(.factButtonTapped)
                    } label: {
                        HStack {
                            Text("Get fact")

                            if viewStore.isLoading {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }

                    if let fact = viewStore.fact {
                        Text(fact)
                    }
                }

                Section {
                    Button("Dismiss") {
                        viewStore.send(.dismissButtonTapped)
                    }
                }

                Section {
                    NavigationLink(
                        "Go to Screen A",
                        state: NavigationDemo.Path.State.screenA(
                            ScreenA.State(count: viewStore.count)
                        )
                    )

                    NavigationLink(
                        "Go to Screen B",
                        state: NavigationDemo.Path.State.screenB()
                    )

                    NavigationLink(
                        "Go to Screen C",
                        state: NavigationDemo.Path.State.screenC(
                            ScreenC.State(count: viewStore.count)
                        )
                    )
                }
            }
        }
        .navigationTitle("Screen A")
    }
}

// MARK: - Screen B

@Reducer
struct ScreenB {
    struct State: Codable, Equatable, Hashable {}

    enum Action {
        case screenAButtonTapped
        case screenBButtonTapped
        case screenCButtonTapped
    }

    var body: some Reducer<State, Action> {
        Reduce { _, action in
            switch action {
            case .screenAButtonTapped:
                .none

            case .screenBButtonTapped:
                .none

            case .screenCButtonTapped:
                .none
            }
        }
    }
}

struct ScreenBView: View {
    let store: StoreOf<ScreenB>

    var body: some View {
        Form {
            Section {
                Text(
                    """
                    他の画面のシンボルをコンパイルする必要なく、他の画面へナビゲートする方法を示しています。

                    システムにアクションを送信し、ルート機能がそのアクションを傍受して次の機能をスタックにプッシュすることができます。
                    """
                )
            }

            Button("Decoupled navigation to screen A") {
                store.send(.screenAButtonTapped)
            }

            Button("Decoupled navigation to screen B") {
                store.send(.screenBButtonTapped)
            }

            Button("Decoupled navigation to screen C") {
                store.send(.screenCButtonTapped)
            }
        }
        .navigationTitle("Screen B")
    }
}

// MARK: - Screen C

@Reducer
struct ScreenC {
    @Dependency(\.mainQueue) var mainQueue

    struct State: Codable, Equatable, Hashable {
        var count = 0
        var isTimerRunning = false
    }

    enum Action {
        case startButtonTapped
        case stopButtonTapped
        case timerTick
    }

    enum CancelID {
        case timer
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .startButtonTapped:
                state.isTimerRunning = true
                return .run { send in
                    for await _ in mainQueue.timer(interval: 1) {
                        await send(.timerTick)
                    }
                }
                .cancellable(id: CancelID.timer)
                .concatenate(with: .send(.stopButtonTapped))

            case .stopButtonTapped:
                state.isTimerRunning = false
                return .cancel(id: CancelID.timer)

            case .timerTick:
                state.count += 1
                return .none
            }
        }
    }
}

struct ScreenCView: View {
    let store: StoreOf<ScreenC>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Text(
                    """
                    スタック内で長期にわたるエフェクトを開始した場合、画面が閉じられると自動的にそれが解除されることを示しています。
                    """
                )

                Section {
                    Text("\(viewStore.count)")

                    if viewStore.isTimerRunning {
                        Button("Stop timer") {
                            viewStore.send(.stopButtonTapped)
                        }
                    } else {
                        Button("Start timer") {
                            viewStore.send(.startButtonTapped)
                        }
                    }
                }

                Section {
                    NavigationLink(
                        "Go to Screen A",
                        state: NavigationDemo.Path.State.screenA(
                            ScreenA.State(count: viewStore.count)
                        )
                    )

                    NavigationLink(
                        "Go to Screen B",
                        state: NavigationDemo.Path.State.screenB()
                    )

                    NavigationLink(
                        "Go to Screen C",
                        state: NavigationDemo.Path.State.screenC()
                    )
                }
            }
            .navigationTitle("Screen C")
        }
    }
}
