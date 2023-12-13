import ComposableArchitecture
import SwiftUI

private let description = """
Composable Architectureでウェブソケットを扱う方法を示しています。

`URLSession`のウェブソケット用APIに対して軽量なラッパーを作成し、ソケットエンドポイントに送信、受信、ピングを行うことができます。

テストするには、ソケットサーバーに接続し、その後メッセージを送信してください。

ソケットサーバーはすぐにあなたが送ったのと同じメッセージで返信するはずです。
"""

// MARK: - Feature domain

@Reducer
struct WebSocket {
    @Dependency(\.continuousClock) var clock
    @Dependency(\.webSocket) var webSocket

    struct State: Equatable {
        @PresentationState var alert: AlertState<Action.Alert>?
        var connectivityState = ConnectivityState.disconnected
        var messageToSend = ""
        var receivedMessages: [String] = []

        enum ConnectivityState: String {
            case connected
            case connecting
            case disconnected
        }
    }

    enum Action {
        case alert(PresentationAction<Alert>)
        case connectButtonTapped
        case messageToSendChanged(String)
        case receivedSocketMessage(Result<WebSocketClient.Message, Error>)
        case sendButtonTapped
        case sendResponse(didSucceed: Bool)
        case webSocket(WebSocketClient.Action)

        enum Alert: Equatable {}
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .alert:
                return .none

            case .connectButtonTapped:
                switch state.connectivityState {
                case .connected, .connecting:
                    state.connectivityState = .disconnected
                    return .cancel(id: WebSocketClient.ID())

                case .disconnected:
                    state.connectivityState = .connecting
                    return .run { send in
                        let actions = await webSocket.open(
                            WebSocketClient.ID(),
                            URL(string: "wss://echo.websocket.events")!,
                            []
                        )
                        await withThrowingTaskGroup(of: Void.self) { group in
                            for await action in actions {
                                // 注意：`Effect.{task,run}`でのタスクローカル依存性の変更のため、`group.addTask`の外部で`await send`を呼び出すことはできません。
                                // `Effect(operation: .run { ... })`がある世界では、その明示的なタスクローカル変更を削除することができるかもしれません。
                                group.addTask {
                                    await send(.webSocket(action))
                                }

                                switch action {
                                case .didOpen:
                                    group.addTask {
                                        while !Task.isCancelled {
                                            try await clock.sleep(for: .seconds(10))
                                            try? await webSocket.sendPing(WebSocketClient.ID())
                                        }
                                    }
                                    group.addTask {
                                        for await result in try await webSocket.receive(WebSocketClient.ID()) {
                                            await send(.receivedSocketMessage(result))
                                        }
                                    }

                                case .didClose:
                                    return
                                }
                            }
                        }
                    }
                    .cancellable(id: WebSocketClient.ID())
                }

            case let .messageToSendChanged(message):
                state.messageToSend = message
                return .none

            case let .receivedSocketMessage(.success(message)):
                if case let .string(string) = message {
                    state.receivedMessages.append(string)
                }
                return .none

            case .receivedSocketMessage(.failure):
                return .none

            case .sendButtonTapped:
                let messageToSend = state.messageToSend
                state.messageToSend = ""
                return .run { send in
                    try await webSocket.send(WebSocketClient.ID(), .string(messageToSend))
                    await send(.sendResponse(didSucceed: true))
                } catch: { _, send in
                    await send(.sendResponse(didSucceed: false))
                }
                .cancellable(id: WebSocketClient.ID())

            case .sendResponse(didSucceed: false):
                state.alert = AlertState {
                    TextState("Could not send socket message. Connect to the server first, and try again.")
                }
                return .none

            case .sendResponse(didSucceed: true):
                return .none

            case .webSocket(.didClose):
                state.connectivityState = .disconnected
                return .cancel(id: WebSocketClient.ID())

            case .webSocket(.didOpen):
                state.connectivityState = .connected
                state.receivedMessages.removeAll()
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

// MARK: - Feature view

struct WebSocketView: View {
    @State var store = Store(initialState: WebSocket.State()) {
        WebSocket()
    }

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section {
                    AboutView(description: description)
                }

                Section {
                    VStack(alignment: .leading) {
                        Button(
                            viewStore.connectivityState == .connected
                                ? "Disconnect"
                                : viewStore.connectivityState == .disconnected
                                ? "Connect"
                                : "Connecting..."
                        ) {
                            viewStore.send(.connectButtonTapped)
                        }
                        .buttonStyle(.bordered)
                        .tint(
                            viewStore.connectivityState == .connected
                                ? .red
                                : .green
                        )

                        HStack {
                            TextField(
                                "Type message here",
                                text: viewStore.binding(
                                    get: \.messageToSend,
                                    send: { .messageToSendChanged($0) }
                                )
                            )
                            .textFieldStyle(.roundedBorder)

                            Button("Send") {
                                viewStore.send(.sendButtonTapped)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }

                Section {
                    Text("Status: \(viewStore.connectivityState.rawValue)")
                        .foregroundStyle(.secondary)
                    Text(viewStore.receivedMessages.reversed().joined(separator: "\n"))
                } header: {
                    Text("Received messages")
                }
            }
            .alert(
                store: store.scope(
                    state: \.$alert,
                    action: \.alert
                )
            )
            .navigationTitle("Web Socket")
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        WebSocketView(store: Store(initialState: WebSocket.State(receivedMessages: ["Hi"])) {
            WebSocket()
        })
    }
}
