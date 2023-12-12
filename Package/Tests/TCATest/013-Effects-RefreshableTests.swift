import ComposableArchitecture
@testable import TCA
import XCTest

@MainActor
final class RefreshableTests: XCTestCase {
    func testHappyPath() async {
        let store = TestStore(initialState: Refreshable.State()) {
            Refreshable()
        } withDependencies: {
            $0.continuousClock = ImmediateClock()
            $0.factClient.fetch = {
                "\($0) is a good number."
            }
        }

        await store.send(.incrementButtonTapped) {
            $0.count = 1
        }

        await store.send(.refresh)

        await store.receive(\.factResponse.success) {
            $0.fact = "1 is a good number."
        }
    }

    func testUnhappyPath() async {
        struct FactError: Equatable, Error {}

        let store = TestStore(initialState: Refreshable.State()) {
            Refreshable()
        } withDependencies: {
            $0.continuousClock = ImmediateClock()
            $0.factClient.fetch = { _ in
                throw FactError()
            }
        }

        await store.send(.incrementButtonTapped) {
            $0.count = 1
        }

        await store.send(.refresh)
        await store.receive(\.factResponse.failure)
    }

    func testCancellation() async {
        let store = TestStore(initialState: Refreshable.State()) {
            Refreshable()
        } withDependencies: {
            $0.continuousClock = ImmediateClock()
            $0.factClient.fetch = {
                try await Task.sleep(for: .seconds(1))
                return "\($0) is a good number."
            }
        }

        await store.send(.incrementButtonTapped) {
            $0.count = 1
        }

        await store.send(.refresh)
        await store.send(.cancelButtonTapped)
    }
}
