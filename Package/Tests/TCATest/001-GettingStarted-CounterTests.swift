import ComposableArchitecture
@testable import TCA
import XCTest

@MainActor
final class CounterTests: XCTestCase {
    func testCount() async {
        // テスト用のStore作成
        let store = TestStore(initialState: Counter.State()) {
            Counter()
        }

        await store.send(.incrementButtonTapped) {
            // やっていることはXCTAssertEqual($0.count, 1)
            $0.count = 1
        }

        await store.send(.decrementButtonTapped) {
            // やっていることはXCTAssertEqual($0.count, 0)
            $0.count = 0
        }

        await store.send(.decrementButtonTapped) {
            // やっていることはXCTAssertEqual($0.count, -1)
            $0.count = -1
        }
    }
}
