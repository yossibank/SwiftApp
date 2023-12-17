import ComposableArchitecture
import SwiftUI

private let description = """
Composable Architectureで進行中のエフェクトをキャンセルする方法を示しています。

ステッパーを使って数字を数え、"Number fact"ボタンをタップしてAPIを使用してその数字についてのランダムな事実を取得します。

APIリクエストが進行中の間、"Cancel"をタップしてエフェクトをキャンセルし、アプリケーションにデータがフィードバックされるのを防ぐことができます。

リクエストが進行中の間にステッパーを操作すると、それもキャンセルされます。
"""

// MARK: - Feature doamin

@Reducer
struct EffectsCancellation {
    @Dependency(\.factClient) var factClient

    struct State: Equatable {
        var count = 0
        var currentFact: String?
        var isFactRequestInFlight = false
    }

    enum Action {
        case cancelButtonTapped
        case stepperChanged(Int)
        case factButtonTapped
        case factResponse(Result<String, Error>)
    }

    private enum CancelID {
        case factRequest
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .cancelButtonTapped:
                state.isFactRequestInFlight = false
                return .cancel(id: CancelID.factRequest)

            case let .stepperChanged(value):
                state.count = value
                state.currentFact = nil
                state.isFactRequestInFlight = false
                return .cancel(id: CancelID.factRequest)

            case .factButtonTapped:
                state.currentFact = nil
                state.isFactRequestInFlight = true
                return .run { [count = state.count] send in
                    await send(.factResponse(Result {
                        try await factClient.fetch(count)
                    }))
                }
                .cancellable(id: CancelID.factRequest)

            case let .factResponse(.success(response)):
                state.isFactRequestInFlight = false
                state.currentFact = response
                return .none

            case .factResponse(.failure):
                state.isFactRequestInFlight = false
                return .none
            }
        }
    }
}

// MARK: - Feature view

struct EffectsCancellationView: View {
    @State private var store = Store(initialState: EffectsCancellation.State()) {
        EffectsCancellation()
    }

    @Environment(\.openURL) private var openURL

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section {
                    AboutView(description: description)
                }

                Section {
                    Stepper(
                        "\(viewStore.count)",
                        value: viewStore.binding(
                            get: \.count,
                            send: { .stepperChanged($0) }
                        )
                    )

                    if viewStore.isFactRequestInFlight {
                        HStack {
                            Button("Cancel") {
                                viewStore.send(.cancelButtonTapped)
                            }
                            Spacer()
                            ProgressView()
                                .id(UUID())
                        }
                    } else {
                        Button("Number fact") {
                            viewStore.send(.factButtonTapped)
                        }
                        .disabled(viewStore.isFactRequestInFlight)
                    }

                    viewStore.currentFact.map {
                        Text($0)
                            .padding(.vertical, 8)
                    }
                }

                Section {
                    Button("Number facts provided by numbersapi.com") {
                        openURL(URL(string: "http://numbersapi.com")!)
                    }
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderless)
        }
        .navigationTitle("Effects Cancellation")
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        EffectsCancellationView()
    }
}
