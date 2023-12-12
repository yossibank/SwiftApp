import ComposableArchitecture
import SwiftUI

private let description = """
Composable ArchitectureでSwiftUIの`refreshable`APIを使う方法を示しています。

"-" と "+" ボタンを使って数を増減させ、その後下にスワイプしてその数についての事実をリクエストしてください。

`.send` メソッドには、特定の状態が真である間、中断して待つことを可能にするオーバーロードがあります。

このメソッドを使用して、データを取得中であることをSwiftUIに伝えることができ、ローディングインジケーターを表示し続けるようにすることができます。
"""

// MARK: - Feature domain

@Reducer
struct Refreshable {
    @Dependency(\.factClient) var factClient

    struct State: Equatable {
        var count = 0
        var fact: String?
    }

    enum Action {
        case cancelButtonTapped
        case decrementButtonTapped
        case incrementButtonTapped
        case factResponse(Result<String, Error>)
        case refresh
    }

    private enum CancelID {
        case factRequest
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .cancelButtonTapped:
                return .cancel(id: CancelID.factRequest)

            case .decrementButtonTapped:
                state.count -= 1
                return .none

            case .incrementButtonTapped:
                state.count += 1
                return .none

            case let .factResponse(.success(fact)):
                state.fact = fact
                return .none

            case .factResponse(.failure):
                // 必要に応じてエラー処理をする場所
                return .none

            case .refresh:
                state.fact = nil
                return .run { [count = state.count] send in
                    await send(
                        .factResponse(Result {
                            try await factClient.fetch(count)
                        }),
                        animation: .default
                    )
                }
                .cancellable(id: CancelID.factRequest)
            }
        }
    }
}

// MARK: - Feature view

struct RefreshableView: View {
    @State private var store = Store(initialState: Refreshable.State()) {
        Refreshable()
    }

    @State private var isLoading = false

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List {
                Section {
                    AboutView(description: description)
                }

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
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderless)

                if let fact = viewStore.fact {
                    Text(fact)
                        .bold()
                }

                if isLoading {
                    Button("Cancel") {
                        viewStore.send(
                            .cancelButtonTapped,
                            animation: .default
                        )
                    }
                }
            }
            .refreshable {
                isLoading = true

                defer {
                    isLoading = false
                }

                await viewStore.send(.refresh).finish()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    RefreshableView()
}
