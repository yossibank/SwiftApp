import ComposableArchitecture
import SwiftUI

private let description = """
Composable Architectureでタイマーを扱う方法を示しています。

これは、Composable Architectureに含まれるSwift Clocksライブラリによって提供されるclockの`.timer`メソッドを使用しています。

このヘルパーは、非同期コード内で時間を扱うための`AsyncSequence`に適合したAPIを提供します。
"""

// MARK: - Feature domain

@Reducer
struct Timers {
    @Dependency(\.continuousClock) var clock

    struct State: Equatable {
        var isTimerActive = false
        var secondsElapsed = 0
    }

    enum Action {
        case onDisappear
        case timerTicked
        case toggleTimerButtonTapped
    }

    private enum CancelID {
        case timer
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onDisappear:
                return .cancel(id: CancelID.timer)

            case .timerTicked:
                state.secondsElapsed += 1
                return .none

            case .toggleTimerButtonTapped:
                state.isTimerActive.toggle()
                return .run { [isTimerActive = state.isTimerActive] send in
                    guard isTimerActive else {
                        return
                    }

                    for await _ in clock.timer(interval: .seconds(1)) {
                        await send(
                            .timerTicked,
                            animation: .interpolatingSpring(
                                stiffness: 3000,
                                damping: 40
                            )
                        )
                    }
                }
                .cancellable(id: CancelID.timer, cancelInFlight: true)
            }
        }
    }
}

// MARK: - Feature view

struct TimersView: View {
    @State private var store = Store(initialState: Timers.State()) {
        Timers()
    }

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                AboutView(description: description)

                ZStack {
                    Circle()
                        .fill(
                            AngularGradient(
                                gradient: Gradient(
                                    colors: [
                                        .blue.opacity(0.3),
                                        .blue,
                                        .blue,
                                        .green,
                                        .green,
                                        .yellow,
                                        .yellow,
                                        .red,
                                        .red,
                                        .purple,
                                        .purple,
                                        .purple.opacity(0.3)
                                    ]
                                ),
                                center: .center
                            )
                        )
                        .rotationEffect(.degrees(-90))

                    GeometryReader { proxy in
                        Path { path in
                            path.move(
                                to: .init(
                                    x: proxy.size.width / 2,
                                    y: proxy.size.height / 2
                                )
                            )
                            path.addLine(
                                to: .init(
                                    x: proxy.size.width / 2,
                                    y: 0
                                )
                            )
                        }
                        .stroke(.primary, lineWidth: 3)
                        .rotationEffect(.degrees(Double(viewStore.secondsElapsed) * 360 / 60))
                    }
                }
                .aspectRatio(1, contentMode: .fit)
                .frame(maxWidth: 280)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)

                Button {
                    viewStore.send(.toggleTimerButtonTapped)
                } label: {
                    Text(viewStore.isTimerActive ? "Stop" : "Start")
                        .padding(8)
                }
                .frame(maxWidth: .infinity)
                .tint(viewStore.isTimerActive ? .red : .accentColor)
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("Timers")
            .onDisappear {
                viewStore.send(.onDisappear)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        TimersView()
    }
}
