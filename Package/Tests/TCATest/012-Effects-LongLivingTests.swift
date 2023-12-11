import ComposableArchitecture
@testable import TCA
import XCTest

@MainActor
final class EffectsLongLivingTests: XCTestCase {
    func testReducer() async {
        let (screenshots, takeScreenshot) = AsyncStream.makeStream(of: Void.self)

        let store = TestStore(initialState: EffectsLongLiving.State()) {
            EffectsLongLiving()
        } withDependencies: {
            $0.screenshots = { screenshots }
        }

        let task = await store.send(.task)

        // スクリーンショットを撮られることをシミュレートする
        takeScreenshot.yield()

        await store.receive(\.userDidTakeScreenshotNotification) {
            $0.screenshotCount = 1
        }

        // 画面が消えることをシミュレートする
        await task.cancel()

        // スクリーンショットが撮られたことをシミュレートして、エフェクトが実行されないことを示す
        takeScreenshot.yield()
    }
}
