import ComposableArchitecture
@testable import TCA
import XCTest

@MainActor
final class CounterTest: XCTestCase {
    func testCount() async {
        let store = TestStore(initialState: Counter.State()) {
            Counter()
        }

        await store.send(.incrementButtonTapped) {
            $0.count = 1
        }

        await store.send(.decrementButtonTapped) {
            $0.count = 0
        }

        await store.send(.decrementButtonTapped) {
            $0.count = -1
        }
    }
}
