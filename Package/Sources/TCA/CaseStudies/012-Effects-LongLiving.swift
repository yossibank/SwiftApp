import ComposableArchitecture
import SwiftUI

private let description = """
Notification Centerからの通知のような長期にわたるエフェクトの扱い方、およびエフェクトの寿命をビューの寿命に結びつける方法を示しています。

このアプリケーションをシミュレータで実行し、メニューの*Device › Screenshot*に移動してスクリーンショットを何枚か撮り、UIがその回数を数える様子を観察してください。

その後、別の画面に移動してそこでスクリーンショットを撮り、この画面がそれらのスクリーンショットをカウントしないことを観察してください。

通知エフェクトは画面を離れると自動的にキャンセルされ、画面に入ると再開されます。
"""

// MARK: - Feature domain

@Reducer
struct EffectsLongLiving {
    @Dependency(\.screenshots) var screenshots

    struct State: Equatable {
        var screenshotCount = 0
    }

    enum Action {
        case task
        case userDidTakeScreenshotNotification
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .task:
                // Viewが表示され、スクリーンショットが撮られた時に発行されるエフェクトを開始する
                return .run { send in
                    for await _ in await screenshots() {
                        await send(.userDidTakeScreenshotNotification)
                    }
                }

            case .userDidTakeScreenshotNotification:
                state.screenshotCount += 1
                return .none
            }
        }
    }
}

// MARK: - Feature view

struct EffectsLongLivingView: View {
    @State private var store = Store(initialState: EffectsLongLiving.State()) {
        EffectsLongLiving()
    }

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section {
                    AboutView(description: description)
                }

                Text("A screenshot of this screen has been taken \(viewStore.screenshotCount) times.")
                    .font(.headline)

                Section {
                    NavigationLink(destination: detailView) {
                        Text("Navigate to another screen")
                    }
                }
            }
            .navigationTitle("Effects Long-Living")
            .task {
                await viewStore.send(.task).finish()
            }
        }
    }

    var detailView: some View {
        Text(
            """
            この画面のスクリーンショットを数回撮り、
            その後に前の画面に戻って、
            それらのスクリーンショットがカウントされていないことを確認してください。
            """
        )
        .padding(.horizontal, 32)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        EffectsLongLivingView()
    }
}
