import ComposableArchitecture
import SwiftUI

private let description = """
アプリケーションの状態の変更がアニメーションを駆動する方法を示しています。`Store`は送信されたアクションを同期的に処理するため、Composable Architectureで通常のSwiftUIと同様にアニメーションを実行することができます。

ストアにアクションが送信されたときに状態の変更をアニメーションするには、明示的なアニメーションを伴って渡すことができますし、または`withAnimation`ブロック内で`viewStore.send`を呼び出すこともできます。

バインディングを通じて状態の変更をアニメーションするには、`Binding`上で`.animation`メソッドを使用します。

エフェクトを介して非同期に状態の変更をアニメーションするには、アニメーションを伴うアクションを送信できる`Effect.run`スタイルのエフェクトを使用します。

画面上のどこかをタップまたはドラッグしてドットを動かしたり、画面の下部のトグルを切り替えることで試してみてください。
"""

// MARK: - Feature domain

@Reducer
struct Animations {
    private enum CancelID {
        case rainbow
    }

    @Dependency(\.continuousClock) var clock

    struct State: Equatable {
        @PresentationState var alert: AlertState<Action.Alert>?
        var circleCenter: CGPoint?
        var circleColor: Color = .black
        var isCircleScaled = false
    }

    enum Action: Sendable {
        case alert(PresentationAction<Alert>)
        case circleScaleToggleChanged(Bool)
        case rainbowButtonTapped
        case resetButtonTapped
        case setColor(Color)
        case tapped(CGPoint)

        enum Alert: Sendable {
            case resetConfirmationButtonTapped
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .alert(.presented(.resetConfirmationButtonTapped)):
                state = State()
                return .cancel(id: CancelID.rainbow)

            case .alert:
                return .none

            case let .circleScaleToggleChanged(isScaled):
                state.isCircleScaled = isScaled
                return .none

            case .rainbowButtonTapped:
                return .run { send in
                    for color in [Color.red, .blue, .green, .orange, .pink, .purple, .yellow, .black] {
                        await send(.setColor(color), animation: .linear)
                        try await clock.sleep(for: .seconds(1))
                    }
                }
                .cancellable(id: CancelID.rainbow)

            case .resetButtonTapped:
                state.alert = AlertState {
                    TextState("Reset state?")
                } actions: {
                    ButtonState(
                        role: .destructive,
                        action: .send(
                            .resetConfirmationButtonTapped,
                            animation: .default
                        )
                    ) {
                        TextState("Reset")
                    }
                    ButtonState(role: .cancel) {
                        TextState("Cancel")
                    }
                }
                return .none

            case let .setColor(color):
                state.circleColor = color
                return .none

            case let .tapped(point):
                state.circleCenter = point
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

// MARK: - Feature view

struct AnimationsView: View {
    @State private var store = Store(initialState: Animations.State()) {
        Animations()
    }

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading) {
                Text(description)
                    .font(.body)
                    .padding()
                    .gesture(
                        DragGesture(minimumDistance: 0).onChanged { gesture in
                            viewStore.send(
                                .tapped(gesture.location),
                                animation: .interactiveSpring(
                                    response: 0.25,
                                    dampingFraction: 0.1
                                )
                            )
                        }
                    )
                    .overlay {
                        GeometryReader { proxy in
                            Circle()
                                .fill(viewStore.circleColor)
                                .colorInvert()
                                .blendMode(.difference)
                                .frame(width: 50, height: 50)
                                .scaleEffect(viewStore.isCircleScaled ? 2 : 1)
                                .position(
                                    x: viewStore.circleCenter?.x ?? proxy.size.width / 2,
                                    y: viewStore.circleCenter?.y ?? proxy.size.height / 2
                                )
                                .offset(y: viewStore.circleCenter == nil ? 0 : -44)
                        }
                    }

                Toggle(
                    "Big mode",
                    isOn: viewStore.binding(
                        get: \.isCircleScaled,
                        send: { .circleScaleToggleChanged($0) }
                    )
                    .animation(
                        .interactiveSpring(
                            response: 0.25,
                            dampingFraction: 0.1
                        )
                    )
                )
                .padding()

                Button("Rainbow") {
                    viewStore.send(
                        .rainbowButtonTapped,
                        animation: .linear
                    )
                }
                .padding([.horizontal, .bottom])

                Button("Reset") {
                    viewStore.send(.resetButtonTapped)
                }
                .padding([.horizontal, .bottom])
            }
            .alert(
                store: store.scope(
                    state: \.$alert,
                    action: \.alert
                )
            )
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Preview

#Preview {
    Group {
        NavigationStack {
            AnimationsView()
        }

        NavigationStack {
            AnimationsView()
        }
        .environment(\.colorScheme, .dark)
    }
}

// MARK: - Test

// import XCTest
//
// @MainActor
// final class AnimationsTests: XCTestCase {
//    func testRainbow() async {
//        let clock = TestClock()
//
//        let store = TestStore(initialState: Animations.State()) {
//            Animations()
//        } withDependencies: {
//            $0.continuousClock = clock
//        }
//
//        await store.send(.rainbowButtonTapped)
//        await store.receive(\.setColor) {
//            $0.circleColor = .red
//        }
//
//        await clock.advance(by: .seconds(1))
//        await store.receive(\.setColor) {
//            $0.circleColor = .blue
//        }
//
//        await clock.advance(by: .seconds(1))
//        await store.receive(\.setColor) {
//            $0.circleColor = .green
//        }
//
//        await clock.advance(by: .seconds(1))
//        await store.receive(\.setColor) {
//            $0.circleColor = .orange
//        }
//
//        await clock.advance(by: .seconds(1))
//        await store.receive(\.setColor) {
//            $0.circleColor = .pink
//        }
//
//        await clock.advance(by: .seconds(1))
//        await store.receive(\.setColor) {
//            $0.circleColor = .purple
//        }
//
//        await clock.advance(by: .seconds(1))
//        await store.receive(\.setColor) {
//            $0.circleColor = .yellow
//        }
//
//        await clock.advance(by: .seconds(1))
//        await store.receive(\.setColor) {
//            $0.circleColor = .black
//        }
//
//        await clock.run()
//    }
//
//    func testReset() async {
//        let clock = TestClock()
//
//        let store = TestStore(initialState: Animations.State()) {
//            Animations()
//        } withDependencies: {
//            $0.continuousClock = clock
//        }
//
//        await store.send(.rainbowButtonTapped)
//        await store.receive(\.setColor) {
//            $0.circleColor = .red
//        }
//
//        await clock.advance(by: .seconds(1))
//        await store.receive(\.setColor) {
//            $0.circleColor = .blue
//        }
//
//        await store.send(.resetButtonTapped) {
//            $0.alert = AlertState {
//                TextState("Reset state?")
//            } actions: {
//                ButtonState(
//                    role: .destructive,
//                    action: .send(
//                        .resetConfirmationButtonTapped,
//                        animation: .default
//                    )
//                ) {
//                    TextState("Reset")
//                }
//                ButtonState(role: .cancel) {
//                    TextState("Cancel")
//                }
//            }
//        }
//
//        await store.send(.alert(.presented(.resetConfirmationButtonTapped))) {
//            $0 = Animations.State()
//        }
//
//        await store.finish()
//    }
// }
