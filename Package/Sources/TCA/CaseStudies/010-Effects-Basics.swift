import ComposableArchitecture
import SwiftUI

private let description = """
Composable Architectureで構築された機能に副作用を導入する方法を示しています。

副作用とは、外部の世界で実行する必要がある作業の単位です。

たとえば、APIリクエストはHTTPを介して外部サービスに到達する必要があり、それには多くの不確実性と複雑さが伴います。

私たちのアプリケーションで行う多くのことには、タイマー、データベースのリクエスト、ファイルアクセス、ソケット接続、およびデバウンス、スロットリング、遅延などの時計が関与する場合（など）の副作用が関係しており、通常、テストが難しいです。

このアプリケーションには単純な副作用があります：「Number fact」をタップすると、その数についてのトリビアに関するAPIリクエストがトリガーされます。

この効果はリデューサーによって処理され、効果が期待通りに動作することを確認するために完全なテストスイートが書かれています。
"""

// MARK: - Feature domain

@Reducer
struct EffectsBasics {
    @Dependency(\.continuousClock) var clock
    @Dependency(\.factClient) var factClient

    struct State: Equatable {
        var count = 0
        var isNumberFactRequestInFlight = false
        var numberFact: String?
    }

    enum Action {
        case decrementButtonTapped
        case decrementDelayResponse
        case incrementButtonTapped
        case numberFactButtonTapped
        case numberFactResponse(Result<String, Error>)
    }

    private enum CancelID {
        case delay
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .decrementButtonTapped:
                state.count -= 1
                state.numberFact = nil
                // カウントが負の場合、1秒後にカウントを再び増加させるエフェクトを返す
                return state.count >= 0
                    ? .none
                    : .run { send in
                        try await clock.sleep(for: .seconds(1))
                        await send(.decrementDelayResponse)
                    }
                    .cancellable(id: CancelID.delay)

            case .decrementDelayResponse:
                if state.count < 0 {
                    state.count += 1
                }
                return .none

            case .incrementButtonTapped:
                state.count += 1
                state.numberFact = nil
                return state.count >= 0
                    ? .cancel(id: CancelID.delay)
                    : .none

            case .numberFactButtonTapped:
                state.isNumberFactRequestInFlight = true
                state.numberFact = nil
                // APIから数値に関する事実をフェッチするエフェクトを返し、
                // その値をリデューサーの`numberFactResponse`アクションに返す
                return .run { [count = state.count] send in
                    await send(.numberFactResponse(Result {
                        try await factClient.fetch(count)
                    }))
                }

            case let .numberFactResponse(.success(response)):
                state.isNumberFactRequestInFlight = false
                state.numberFact = response
                return .none

            case .numberFactResponse(.failure):
                // ここでエラーを何らかの方法で処理することができる
                // 例) アラートを表示するなど
                state.isNumberFactRequestInFlight = false
                return .none
            }
        }
    }
}

// MARK: - Feature view

struct EffectsBasicsView: View {
    @State private var store = Store(initialState: EffectsBasics.State()) {
        EffectsBasics()
    }

    @Environment(\.openURL) private var openURL

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section {
                    AboutView(description: description)
                }

                Section {
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

                    Button("Number fact") {
                        viewStore.send(.numberFactButtonTapped)
                    }
                    .frame(maxWidth: .infinity)

                    if viewStore.isNumberFactRequestInFlight {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            // SwiftUIのバグでProgressViewが2回目に表示されない
                            // 新しいIDを与えることで解決している
                            .id(UUID())
                    }

                    if let numberFact = viewStore.numberFact {
                        Text(numberFact)
                    }
                }

                Section {
                    Button("Number facts provided by numbersapi.com") {
                        openURL(URL(string: "https://numbersapi.com")!)
                    }
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderless)
        }
        .navigationTitle("Effects")
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        EffectsBasicsView()
    }
}
