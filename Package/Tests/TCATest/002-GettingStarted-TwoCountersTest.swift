import ComposableArchitecture
@testable import TCA
import XCTest

@MainActor
final class TwoCountersTest: XCTestCase {
    func testCount() async {
        let store = TestStore(initialState: TwoCounters.State()) {
            TwoCounters()
        }

        await store.send(.counter1(.incrementButtonTapped)) {
            $0.counter1.count = 1
            $0.counter2.count = 0
        }

        await store.send(.counter2(.decrementButtonTapped)) {
            $0.counter1.count = 1
            $0.counter2.count = -1
        }
    }
}
